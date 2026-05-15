class_name TurnSequenceSystem
extends SystemNode

# --- Fases da Máquina de Estados ---
enum Phase {
	IDLE = 0, TURN_START, STACK_RESOLUTION, PLAYER_ACTION, EFFECT_RESOLUTION, POST_DRAW, TURN_END
}

var _game_entity: int = -1
var _seq: int = 0


func init_system() -> void:
	world.events.on_component_added.connect(_check_game_entity)
	world.events.on_effects_completed.connect(_on_effects_completed)
	world.events.on_draw_completed.connect(_on_draw_completed)
	replicator.batch_applied.connect(_on_batch_applied)

	var vs = world.get_system(ValidationSystem)
	if vs:
		vs.action_validated.connect(_on_action_validated)


# ============================================================
# DESCOBERTA DA GAME ENTITY
# ============================================================


func _check_game_entity(entity: int, type: Script) -> void:
	if type == TurnComponent and _game_entity == -1:
		_game_entity = entity
		print("achou ts")
		world.events.on_component_added.disconnect(_check_game_entity)


# ============================================================
# SINCRONIZAÇÃO — BATCH APLICADO
# ============================================================
# Todos os peers sincronizam _phase com TurnComponent.phase e locks de drag.
# Apenas o servidor decide transições de turno (_start_turn).


func _on_batch_applied(batch: Array[Dictionary], _sync_id: String) -> void:
	if _game_entity == -1 or not world.entities.exists(_game_entity):
		return

	var turn_comp: TurnComponent = null

	for entry in batch:
		if entry.type == TurnComponent.resource_path:
			turn_comp = world.get_component(_game_entity, TurnComponent) as TurnComponent

	if turn_comp == null:
		return

	_update_locks()

	if not multiplayer.is_server():
		return

	if turn_comp.phase == Phase.IDLE:
		_start_turn()


func _update_locks() -> void:
	var turn := world.get_component(_game_entity, TurnComponent) as TurnComponent
	if not turn:
		return

	var my_id := multiplayer.get_unique_id()
	var is_action_phase := turn.phase == Phase.PLAYER_ACTION

	world.query([CardComponent, DraggableComponent]).for_each(
		func(_e, comps):
			var card := comps[0] as CardComponent
			var drag := comps[1] as DraggableComponent
			drag.locked = not (
				is_action_phase and turn.current_player == my_id and card.zone_id == my_id
			)
	)

	world.query([PlayerComponent]).for_each(
		func(_e, comps):
			var player := comps[0] as PlayerComponent
			var hand = Zones.get_zone(player.hand_zone_id).get_child(0) as PlayerHand
			if turn.current_player == player.peer_id:
				hand.raise_hand()
			else:
				hand.lower_hand()
	)


# ============================================================
# CALLBACK DE VALIDAÇÃO
# ============================================================


func _on_action_validated(sender: int, action: String, data: Dictionary) -> void:
	if not multiplayer.is_server():
		return

	match action:
		"play_card":
			_set_phase(Phase.STACK_RESOLUTION)
			_resolve_played_card(sender, data)
		"draw_card":
			_begin_draw(1)


# ============================================================
# EVENTOS DO JOGO — RESULTADOS ASSÍNCRONOS
# ============================================================


func _on_effects_completed() -> void:
	"""
	Chamado após EffectSystem processar todos os efeitos da carta jogada.
	Sempre encerra o turno — a acumulação de DrawStack é tratada
	no início do PRÓXIMO turno (TURN_START → STACK_RESOLUTION).
	"""
	if not multiplayer.is_server():
		return

	_end_turn()


func _on_draw_completed(player: int, amount: int, from_stack: bool) -> void:
	"""
	Chamado pelo DealerSystem após cartas serem compradas.
	O comportamento depende da fase atual:
	- STACK_RESOLUTION: compra forçada do stack → turno acaba
	- POST_DRAW: verifica modo de draw para decidir próximo passo
	"""
	if not multiplayer.is_server():
		return
	var turn_comp: TurnComponent = world.get_component(_game_entity, TurnComponent) as TurnComponent
	match turn_comp.phase:
		Phase.STACK_RESOLUTION:
			# Jogador não tinha +2/+4, comprou automaticamente → fim do turno
			_end_turn()

		Phase.POST_DRAW:
			var draw_mode := _get_draw_mode()
			if draw_mode == DrawConfigComponent.DrawMode.DRAW_UNTIL_PLAYABLE:
				var vs = world.get_system(ValidationSystem)
				if vs and vs.player_has_playable(player):
					_set_phase(Phase.PLAYER_ACTION)
				else:
					# Ainda não tem jogável → compra de novo
					_begin_draw(1)
			else:
				# DRAW_ONE_PASS: comprou 1, acabou o turno
				_end_turn()

		_:
			# Fase inesperada durante draw → encerra para evitar loop infinito
			push_warning(
				"TurnSequenceSystem: on_draw_completed em fase inesperada: %d" % turn_comp.phase
			)
			_end_turn()


# ============================================================
# MÁQUINA DE ESTADOS — TRANSIÇÕES
# ============================================================


func _start_turn() -> void:
	"""
	Ponto de entrada de cada turno.
	Chamado quando TurnComponent sincronizado com _phase == IDLE.
	"""
	if not multiplayer.is_server():
		return

	_set_phase(Phase.TURN_START)

	var turn: TurnComponent = world.get_component(_game_entity, TurnComponent) as TurnComponent
	if not turn:
		push_warning("TurnSequenceSystem: TurnComponent não encontrado!")
		return

	_check_playable(turn.current_player)


func _resolve_played_card(sender: int, data: Dictionary) -> void:
	var entity = data.get("entity", -1)
	if not world.entities.exists(entity):
		_end_turn()
		return

	var card = world.get_component(entity, CardComponent) as CardComponent
	if not card:
		_end_turn()
		return

	# Verifica se a carta tem DRAW effect (acumula stack)
	var amount = 0
	var efeito_draw = false
	if world.has_component(entity, CardEffectsComponent):
		var effects = world.get_component(entity, CardEffectsComponent) as CardEffectsComponent
		for e in effects.on_play:
			if e.type == Effect.Type.DRAW:
				efeito_draw = true
				amount += e.amount
				break

	if efeito_draw:
		_set_phase(Phase.EFFECT_RESOLUTION)
	else:
		var stack = world.get_component(_game_entity, DrawStackComponent) as DrawStackComponent
		if stack and stack.accumulated > 0:
			# Força compra do stack
			var dealer = world.get_system(DealerSystem)
			if dealer:
				dealer.execute_draw(stack.accumulated, sender)
			stack.accumulated = 0
			replicator.push_state(
				[
					{
						"entity": _game_entity,
						"type": DrawStackComponent.resource_path,
						"data": stack.to_dict()
					}
				],
				"stack_clear_%d" % card.play_order
			)
		else:
			_set_phase(Phase.EFFECT_RESOLUTION)


func _check_playable(player: int) -> void:
	var vs = world.get_system(ValidationSystem)
	if vs and vs.player_has_playable(player):
		_set_phase(Phase.PLAYER_ACTION)
	else:
		_begin_draw(1)


func _end_turn() -> void:
	"""
	Encerra o turno atual e prepara a transição para o próximo.
	"""
	_set_phase(Phase.TURN_END)
	_advance_turn()


func _advance_turn() -> void:
	var turn := world.get_component(_game_entity, TurnComponent) as TurnComponent
	var player_ids := Players.get_player_ids()

	if not turn or player_ids.is_empty():
		return

	var steps := 1 + turn.skip_amount
	var idx := player_ids.find(turn.current_player)
	if idx < 0:
		idx = 0

	turn.current_player = player_ids[
		(idx + turn.direction * steps + player_ids.size() * 10) % player_ids.size()
	]
	turn.skip_amount = 0

	turn.phase = Phase.IDLE

	var sync_id := "turn_%d" % _seq
	_seq += 1
	replicator.push_state(
		[{"entity": _game_entity, "type": TurnComponent.resource_path, "data": turn.to_dict()}],
		sync_id
	)


# ============================================================
# AUXILIARES
# ============================================================


func _begin_draw(amount: int) -> void:
	_set_phase(Phase.POST_DRAW)
	var dealer = world.get_system(DealerSystem)
	if dealer:
		dealer.execute_draw(amount, _get_current_player())


func _set_phase(p: int) -> void:
	var turn_comp := world.get_component(_game_entity, TurnComponent) as TurnComponent
	if not turn_comp:
		return
	turn_comp.phase = p

	var sync_id := "phase_%d" % _seq
	_seq += 1
	replicator.push_state(
		[
			{
				"entity": _game_entity,
				"type": TurnComponent.resource_path,
				"data": turn_comp.to_dict()
			}
		],
		sync_id
	)


func _get_current_player() -> int:
	var turn := world.get_component(_game_entity, TurnComponent) as TurnComponent
	return turn.current_player if turn else -1


func _get_draw_mode() -> int:
	var draw_cfg := world.get_component(_game_entity, DrawConfigComponent) as DrawConfigComponent
	if draw_cfg:
		return draw_cfg.draw_mode
	return DrawConfigComponent.DrawMode.DRAW_ONE_PASS
