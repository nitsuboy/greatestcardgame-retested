class_name DealerSystem
extends SystemNode

@export var deck: CardDeck

var _game_entity: int = -1
var _seq: int = 0


func init_system() -> void:
	Remote.action_received.connect(_on_action)
	world.events.on_component_added.connect(_check_game_entity)


func _check_game_entity(_entity: int, type: Script) -> void:
	if type == TurnComponent and _game_entity == -1:
		_game_entity = _entity


func _on_action(sender: int, action: String, data: Dictionary) -> void:
	if not multiplayer.is_server():
		return

	if action == "draw_card":
		# Validar turno: só o jogador da vez pode comprar
		if _game_entity >= 0 and world.entities.exists(_game_entity):
			var turn = world.get_component(_game_entity, TurnComponent)
			if sender != multiplayer.get_unique_id() and sender != turn.current_player:
				return

		var amount = data.get("amount", 1)
		var target_player = data.get("player", sender)

		var stack_batch: Array[Dictionary] = []
		var drew_from_stack := false
		if world.entities.exists(_game_entity):
			var stack = world.get_component(_game_entity, DrawStackComponent) as DrawStackComponent
			if stack and stack.accumulated > 0:
				amount = stack.accumulated
				stack.accumulated = 0
				stack_batch.append(
					{
						"entity": _game_entity,
						"type": DrawStackComponent.resource_path,
						"data": stack.to_dict()
					}
				)
				drew_from_stack = true

		var batch: Array[Dictionary] = []

		for i in range(amount):
			if deck.draw_pointer > deck.discard_pointer:
				deck.reset()
			var entity = _create_card_entity(target_player)
			if entity < 0:
				break
			var entries = world.get_all_components(entity)
			for entry in entries:
				batch.append(entry)

		for entry in batch:
			world.events.on_card_drawn.emit(entry.entity, target_player)

		if not batch.is_empty() or not stack_batch.is_empty():
			var sync_id = "draw_%d" % _seq
			_seq += 1
			batch.append_array(stack_batch)
			replicator.push_state(batch, sync_id)

		if drew_from_stack:
			Remote.send("end_turn", {})

	elif action == "discard_card":
		var entity = data.entity
		if not world.entities.exists(entity) or not world.has_component(entity, CardComponent):
			return
		var card = world.get_component(entity, CardComponent)
		card.zone_id = 1000
		var sync_id = "discard_%d" % _seq
		_seq += 1
		replicator.push_state(
			[{"entity": entity, "type": CardComponent.resource_path, "data": card.to_dict()}],
			sync_id
		)


func _create_card_entity(player_id: int) -> int:
	var card_data: CardData = deck.draw()
	if not card_data:
		return -1

	var entity = world.create_entity()
	for comp in card_data.components:
		var new_comp = comp.duplicate(true)
		if new_comp is CardComponent:
			new_comp.zone_id = player_id
			new_comp.face_up = false
		world.add_component(entity, new_comp)

	return entity
