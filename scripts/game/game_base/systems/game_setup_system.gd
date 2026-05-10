class_name GameSetupSystem
extends SystemNode

var _seq: int = 0


func init_system() -> void:
	Remote.action_received.connect(_on_action)


func _on_action(sender: int, action: String, data: Dictionary) -> void:
	if action != "start_game":
		return
	if not multiplayer.is_server():
		return

	var batch: Array[Dictionary] = []

	# 1. Cria entidade de turno global
	var turn_entity = world.create_entity()
	var turn_comp = TurnComponent.new()
	world.add_component(turn_entity, turn_comp)
	batch.append(
		{
			"entity": turn_entity,
			"type": ScriptCache.get_path(TurnComponent),
			"data": turn_comp.to_dict()
		}
	)

	# 2. Cria entidade para cada jogador
	for pid in Players.get_player_ids():
		var player_entity = world.create_entity()
		var player_comp = PlayerComponent.new()
		player_comp.peer_id = pid
		player_comp.hand_zone_id = pid  # zone_id = peer_id
		world.add_component(player_entity, player_comp)
		batch.append(
			{
				"entity": player_entity,
				"type": ScriptCache.get_path(PlayerComponent),
				"data": player_comp.to_dict()
			}
		)

	# 3. Distribui 7 cartas para cada jogador
	for pid in Players.get_player_ids():
		for i in range(7):
			var card_entity = _create_card(pid)
			var card_data = world.get_component(card_entity, CardComponent).to_dict()
			batch.append(
				{
					"entity": card_entity,
					"type": ScriptCache.get_path(CardComponent),
					"data": card_data
				}
			)

	var sync_id = "setup_%d" % _seq
	_seq += 1
	replicator.push_state(batch, sync_id)


func _create_card(player_id: int) -> int:
	var entity = world.create_entity()
	var card = CardComponent.new()
	card.color = randi() % 4
	card.value = randi() % 13
	card.zone_id = player_id
	card.face_up = false
	world.add_component(entity, card)
	world.add_component(entity, DraggableComponent.new())
	world.add_component(entity, PlayableComponent.new())
	return entity
