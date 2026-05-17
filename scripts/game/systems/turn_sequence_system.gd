class_name TurnSequenceSystem
extends TurnMachine

# --- Fases da Máquina de Estados ---
enum Phase {
	IDLE = 0, TURN_START, STACK_RESOLUTION, PLAYER_ACTION, EFFECT_RESOLUTION, POST_DRAW, TURN_END
}

const ANIM_DURATION: float = 0.1
const TURN_START_DELAY: float = 0
const DRAW_DELAY: float = ANIM_DURATION * 2.0
const TURN_END_DELAY: float = ANIM_DURATION * 4.0
const PLAY_CARD_DELAY: float = ANIM_DURATION * 2.0

var _game_over: bool = false
var _ending_turn: bool = false


func init_system() -> void:
	_turn_comp_type = TurnComponent
	super()
	world.events.on_effects_completed.connect(_on_effects_completed)
	world.events.on_draw_completed.connect(_on_draw_completed)

	var vs = world.get_system(ValidationSystem)
	if vs:
		vs.action_validated.connect(_on_action_validated)


# ============================================================
# HOOKS — TurnMachine
# ============================================================


func _is_action_phase(phase: int) -> bool:
	return phase == Phase.PLAYER_ACTION


func _on_activate_player_hand(player: PlayerComponent) -> void:
	var zone = Zones.get_zone(player.hand_zone_id)
	if zone and zone.get_child_count() > 0:
		var hand = zone.get_child(0) as PlayerHand
		if hand:
			hand.raise_hand()


func _on_deactivate_player_hand(player: PlayerComponent) -> void:
	var zone = Zones.get_zone(player.hand_zone_id)
	if zone and zone.get_child_count() > 0:
		var hand = zone.get_child(0) as PlayerHand
		if hand:
			hand.lower_hand()


func _on_phase_arrived(phase: int) -> void:
	if not multiplayer.is_server() or _game_over:
		return
	if phase == Phase.IDLE:
		_start_turn()


# ============================================================
# CALLBACK DE VALIDAÇÃO
# ============================================================


func _on_action_validated(sender: int, action: String, data: Dictionary) -> void:
	if not multiplayer.is_server():
		return

	match action:
		"play_card":
			set_phase(Phase.STACK_RESOLUTION)
			await phase_delay(PLAY_CARD_DELAY)
			_resolve_played_card(sender, data)
		"draw_card":
			_begin_draw(1)


# ============================================================
# EVENTOS DO JOGO — RESULTADOS ASSÍNCRONOS
# ============================================================


func _on_effects_completed() -> void:
	"""
	Chamado após EffectSystem processar todos os efeitos da carta jogada.
	Verifica condição de vitória antes de encerrar o turno.
	"""
	if not multiplayer.is_server() or _game_over:
		return

	if _check_win_condition():
		return

	_end_turn()


func _on_draw_completed(player: int, _amount: int, _from_stack: bool) -> void:
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
			await phase_delay(DRAW_DELAY)
			var draw_mode := _get_draw_mode()
			if draw_mode == DrawConfigComponent.DrawMode.DRAW_UNTIL_PLAYABLE:
				var vs = world.get_system(ValidationSystem)
				if vs and vs.player_has_playable(player):
					set_phase(Phase.PLAYER_ACTION)
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
	if not multiplayer.is_server() or _game_over:
		return

	set_phase(Phase.TURN_START)
	await phase_delay(TURN_START_DELAY)

	var turn: TurnComponent = world.get_component(_game_entity, TurnComponent) as TurnComponent
	if not turn:
		push_warning("TurnSequenceSystem: TurnComponent não encontrado!")
		return

	_check_playable(turn.current_player)


func _resolve_played_card(sender: int, data: Dictionary) -> void:
	if _ending_turn:
		# on_effects_completed já disparou, não mexe na fase
		_force_residual_stack_draw(sender, data)
		return

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
		set_phase(Phase.EFFECT_RESOLUTION)
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
			set_phase(Phase.EFFECT_RESOLUTION)


func _force_residual_stack_draw(sender: int, data: Dictionary) -> void:
	if _game_entity == -1 or not world.entities.exists(_game_entity):
		return
	var entity = data.get("entity", -1)
	if not world.entities.exists(entity):
		return
	var card = world.get_component(entity, CardComponent) as CardComponent
	if not card:
		return

	# Se a carta tem DRAW effect, o EffectSystem já acumulou o stack
	if world.has_component(entity, CardEffectsComponent):
		var effects = world.get_component(entity, CardEffectsComponent) as CardEffectsComponent
		for e in effects.on_play:
			if e.type == Effect.Type.DRAW:
				return

	# Stack residual de cartas anteriores: precisa forçar a compra
	var stack = world.get_component(_game_entity, DrawStackComponent) as DrawStackComponent
	if stack and stack.accumulated > 0:
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
			"stack_clear_residual_%d" % card.play_order
		)


func _check_playable(player: int) -> void:
	var vs = world.get_system(ValidationSystem)
	if vs and vs.player_has_playable(player):
		set_phase(Phase.PLAYER_ACTION)
	else:
		_begin_draw(1)


func _end_turn() -> void:
	"""
	Encerra o turno atual e prepara a transição para o próximo.
	Protegido contra re-entrada (on_effects_completed + _resolve_played_card).
	"""
	if _ending_turn:
		return
	_ending_turn = true
	set_phase(Phase.TURN_END)
	await phase_delay(TURN_END_DELAY)
	_ending_turn = false
	_advance_turn()


func _advance_turn() -> void:
	var turn := world.get_component(_game_entity, TurnComponent) as TurnComponent
	var player_ids := Players.get_player_ids()

	if not turn or player_ids.is_empty():
		return

	turn.current_player = advance_next_player(
		player_ids, turn.current_player, turn.direction, turn.skip_amount
	)
	turn.skip_amount = 0

	set_phase(Phase.IDLE)


# ============================================================
# CONDIÇÃO DE VITÓRIA
# ============================================================


func _check_win_condition() -> bool:
	var storage = world.get_storage(PlayerComponent)
	if not storage:
		return false
	for pc in storage.get_all_data():
		var player := pc as PlayerComponent
		if player and player.peer_id == get_current_player():
			if _count_cards_in_zone(player.hand_zone_id) == 0:
				_declare_winner(player.peer_id)
				return true
	return false


func _count_cards_in_zone(zone_id: int) -> int:
	var card_storage = world.get_storage(CardComponent)
	if not card_storage:
		return 0
	var count := 0
	for c in card_storage.get_all_data():
		var card := c as CardComponent
		if card and card.zone_id == zone_id:
			count += 1
	return count


func _declare_winner(peer_id: int) -> void:
	_game_over = true
	_show_victory.rpc(peer_id)
	world.events.on_game_over.emit(peer_id)


@rpc("call_local", "reliable")
func _show_victory(winner_id: int) -> void:
	VictoryScreen.open(winner_id, $"../../front")


func _begin_draw(amount: int) -> void:
	set_phase(Phase.POST_DRAW)
	var dealer = world.get_system(DealerSystem)
	if dealer:
		dealer.execute_draw(amount, get_current_player())


func _get_draw_mode() -> int:
	var draw_cfg := world.get_component(_game_entity, DrawConfigComponent) as DrawConfigComponent
	if draw_cfg:
		return draw_cfg.draw_mode
	return DrawConfigComponent.DrawMode.DRAW_ONE_PASS
