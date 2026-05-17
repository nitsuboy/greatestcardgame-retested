class_name GameSetupSystem
extends SystemNode

var _seq: int = 0


func init_system() -> void:
	Remote.action_received.connect(_on_action)


func _on_action(_sender: int, action: String, _data: Dictionary) -> void:
	if action != "start_game":
		return
	if not multiplayer.is_server():
		return

	var dealer = world.get_system(DealerSystem)
	if not dealer or not dealer.deck:
		return

	dealer.deck.load_cards()
	dealer.deck.shuffle()

	var batch: Array[Dictionary] = []

	# Entidade de jogo global (turno + regras)
	var game_entity = world.create_entity()

	var turn_comp = TurnComponent.new()
	world.add_component(game_entity, turn_comp)
	batch.append(
		{"entity": game_entity, "type": TurnComponent.resource_path, "data": turn_comp.to_dict()}
	)

	var stack_comp = DrawStackComponent.new()
	world.add_component(game_entity, stack_comp)
	batch.append(
		{
			"entity": game_entity,
			"type": DrawStackComponent.resource_path,
			"data": stack_comp.to_dict()
		}
	)

	var game_state = GameStateComponent.new()
	world.add_component(game_entity, game_state)
	batch.append(
		{
			"entity": game_entity,
			"type": GameStateComponent.resource_path,
			"data": game_state.to_dict()
		}
	)

	var draw_cfg = DrawConfigComponent.new()
	world.add_component(game_entity, draw_cfg)
	batch.append(
		{
			"entity": game_entity,
			"type": DrawConfigComponent.resource_path,
			"data": draw_cfg.to_dict()
		}
	)

	# phase já faz parte do TurnComponent (merge TurnPhaseComponent)

	# Entidade para cada jogador
	for pid in Players.get_player_ids():
		var player_entity = world.create_entity()
		var player_comp = PlayerComponent.new()
		player_comp.peer_id = pid
		player_comp.hand_zone_id = pid
		player_comp.is_bot = Players.get_player(pid).get("is_bot", false)
		world.add_component(player_entity, player_comp)
		batch.append(
			{
				"entity": player_entity,
				"type": PlayerComponent.resource_path,
				"data": player_comp.to_dict()
			}
		)

	# Distribui 7 cartas para cada jogador
	for pid in Players.get_player_ids():
		for i in range(7):
			var entity = dealer._create_card_entity(pid)
			if entity < 0:
				break
			var entries = world.get_all_components(entity)
			for entry in entries:
				batch.append(entry)

	# Carta inicial no descarte (zone 999)
	var start_card_data: CardData = null
	while true:
		var candidate: CardData = dealer.deck.draw()
		if not candidate:
			break
		var uno_candidate := candidate as UnoCardData
		if not uno_candidate:
			continue
		if (
			uno_candidate.card_value >= 0
			and uno_candidate.card_value <= 9
			and uno_candidate.card_color >= 0
			and uno_candidate.card_color <= 3
		):
			start_card_data = candidate
			break
		# Carta de efeito — devolve ao deck (volta na reinicialização)
		dealer.deck.discard(candidate)

	if start_card_data:
		var start_entity = world.create_entity()
		for comp in start_card_data.components:
			var new_comp = comp.duplicate(true)
			if new_comp is CardComponent:
				new_comp.zone_id = 999
				new_comp.face_up = true
				new_comp.play_order = 0
			world.add_component(start_entity, new_comp)
		var entries = world.get_all_components(start_entity)
		for entry in entries:
			batch.append(entry)

	# Reconstroi zones e inclui GameStateComponent no batch
	game_state.rebuild(world)
	batch.append(
		{
			"entity": game_entity,
			"type": GameStateComponent.resource_path,
			"data": game_state.to_dict()
		}
	)

	var sync_id = "setup_%d" % _seq
	_seq += 1
	replicator.push_state(batch, sync_id)
