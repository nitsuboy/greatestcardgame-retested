class_name DrawSystem
extends SystemNode

var _seq: int = 0


func init_system() -> void:
	Remote.action_received.connect(_on_action)


func _on_action(sender: int, action: String, data: Dictionary) -> void:
	if action != "draw_card":
		return
	if not multiplayer.is_server():
		return

	var amount = data.get("amount", 1)
	var target_player = data.get("player", sender)
	var batch: Array[Dictionary] = []

	for i in range(amount):
		var entity = world.create_entity()
		var card = CardComponent.new()
		card.color = randi() % 4
		card.value = randi() % 13
		card.zone_id = target_player
		card.face_up = false
		world.add_component(entity, card)
		world.add_component(entity, DraggableComponent.new())
		world.add_component(entity, PlayableComponent.new())
		batch.append(
			{"entity": entity, "type": ScriptCache.get_path(CardComponent), "data": card.to_dict()}
		)

	var sync_id = "draw_%d" % _seq
	_seq += 1
	replicator.push_state(batch, sync_id)
