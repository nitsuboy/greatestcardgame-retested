class_name DealerSystem
extends SystemNode

@export var deck: CardDeck

var _game_entity: int = -1
var _seq: int = 0


func init_system() -> void:
	world.events.on_game_entity_ready.connect(func(e): _game_entity = e)
	Remote.action_received.connect(_on_action)


func _on_action(_sender: int, action: String, data: Dictionary) -> void:
	if not multiplayer.is_server():
		return

	if action == "discard_card":
		var entity = data.entity
		if not world.entities.exists(entity) or not world.has_component(entity, CardComponent):
			return
		var card = world.get_component(entity, CardComponent)
		card.zone_id = 999
		var sync_id = "discard_%d" % _seq
		_seq += 1
		replicator.push_state(
			[{"entity": entity, "type": CardComponent.resource_path, "data": card.to_dict()}],
			sync_id
		)


func execute_draw(amount: int, player: int) -> void:
	if not multiplayer.is_server():
		return

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
		var entity = _create_card_entity(player)
		if entity < 0:
			break
		var entries = world.get_all_components(entity)
		for entry in entries:
			batch.append(entry)

	for entry in batch:
		world.events.on_card_drawn.emit(entry.entity, player)

	if not batch.is_empty() or not stack_batch.is_empty():
		var sync_id = "draw_%d" % _seq
		_seq += 1
		batch.append_array(stack_batch)
		replicator.push_state(batch, sync_id)

	world.events.on_draw_completed.emit(player, amount, drew_from_stack)


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
