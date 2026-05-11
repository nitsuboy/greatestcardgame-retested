class_name DealerSystem
extends SystemNode

@export var deck: CardDeck

var _seq: int = 0


func init_system() -> void:
	Remote.action_received.connect(_on_action)


func _on_action(sender: int, action: String, data: Dictionary) -> void:
	if not multiplayer.is_server():
		return

	if action == "draw_card":
		var amount = data.get("amount", 1)
		var target_player = data.get("player", sender)
		var batch: Array[Dictionary] = []

		for i in range(amount):
			if deck.draw_pointer > deck.discard_pointer:
				deck.reset()
			var entity = _create_card_entity(target_player)
			if entity < 0:
				break
			var card = world.get_component(entity, CardComponent)
			batch.append(
				{"entity": entity, "type": CardComponent.resource_path, "data": card.to_dict()}
			)

		if not batch.is_empty():
			var sync_id = "draw_%d" % _seq
			_seq += 1
			replicator.push_state(batch, sync_id)

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
	var card = CardComponent.new()
	card.color = card_data.card_color
	card.value = card_data.card_value
	card.zone_id = player_id
	card.face_up = false
	world.add_component(entity, card)
	world.add_component(entity, DraggableComponent.new())
	#world.add_component(entity, PlayableComponent.new())

	if card_data.components.size() > 0:
		for comp in card_data.components:
			world.add_component(entity, comp.duplicate(true))

	return entity
