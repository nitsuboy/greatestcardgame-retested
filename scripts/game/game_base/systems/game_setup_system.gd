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

	var dealer = get_parent().dealer_system
	if not dealer or not dealer.deck:
		return

	dealer.deck.load_cards()
	dealer.deck.shuffle()

	var batch: Array[Dictionary] = []

	# Entidade de turno global
	var turn_entity = world.create_entity()
	var turn_comp = TurnComponent.new()
	world.add_component(turn_entity, turn_comp)
	batch.append(
		{"entity": turn_entity, "type": TurnComponent.resource_path, "data": turn_comp.to_dict()}
	)

	# Entidade para cada jogador
	for pid in Players.get_player_ids():
		var player_entity = world.create_entity()
		var player_comp = PlayerComponent.new()
		player_comp.peer_id = pid
		player_comp.hand_zone_id = pid
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
			var card = world.get_component(entity, CardComponent)
			batch.append(
				{"entity": entity, "type": CardComponent.resource_path, "data": card.to_dict()}
			)

	var sync_id = "setup_%d" % _seq
	_seq += 1
	replicator.push_state(batch, sync_id)
