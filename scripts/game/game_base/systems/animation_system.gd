class_name AnimationSystem
extends SystemNode


func init_system() -> void:
	world.events.on_component_added.connect(_on_component_added)


func _on_component_added(entity: int, type: Script) -> void:
	if type != CardComponent:
		return
	if not world.entities.exists(entity):
		return
	if not world.has_component(entity, NodeRef):
		return

	var card_comp = world.get_component(entity, CardComponent) as CardComponent
	var ref = world.get_component(entity, NodeRef) as NodeRef
	if not ref or not ref.node:
		return

	var expected_parent = _get_zone_parent(card_comp.zone_id)
	if not expected_parent:
		return

	var card_node = ref.node
	var current_parent = card_node.get_parent()

	if current_parent != expected_parent:
		var global_pos = card_node.global_position
		if current_parent:
			current_parent.remove_child(card_node)
		expected_parent.add_child(card_node)
		card_node.global_position = global_pos

		await get_tree().process_frame
		if expected_parent.has_method("update_cards"):
			expected_parent.update_cards()


func _get_zone_parent(zone_id: int) -> Node:
	match zone_id:
		1:
			return get_tree().get_first_node_in_group("player1_hand")
		2:
			return get_tree().get_first_node_in_group("player2_hand")
		999:
			return get_tree().get_first_node_in_group("play_zone")
		1000:
			return get_tree().get_first_node_in_group("discard_zone")
		_:
			return get_tree().get_first_node_in_group("player_hand")
