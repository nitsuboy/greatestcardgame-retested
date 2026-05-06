class_name PrototypeSpawner
extends Node


static func init_tree(root: Node) -> void:
	for child in root.get_children():
		if child is PrototypeMarker and not (child as PrototypeMarker).initialized:
			init_existing(child as PrototypeMarker)
		elif child.get_child_count() > 0:
			init_tree(child)


static func init_existing(marker: PrototypeMarker) -> Node:
	var node = marker.get_parent()
	if not PrototypeRegistry.has(marker.prototype_id):
		push_error(
			(
				"PrototypeSpawner: prototype '%s' not registered for node '%s'"
				% [marker.prototype_id, node.name]
			)
		)
		return null

	var entity_id = EntityRegistry.calculate_next_entity_uid()
	node.post_instantiate(entity_id, marker.spawn_data)
	marker.initialized = true
	return node


static func spawn(
	prototype_id: String, entity_id: int, spawn_data: Dictionary, parent_node: Node
) -> void:
	var node = _instantiate(prototype_id, entity_id, spawn_data)
	parent_node.add_child(node)


static func _instantiate(prototype_id: String, entity_id: int, spawn_data: Dictionary) -> Node:
	var scene = PrototypeRegistry.get_scene(prototype_id)
	var node = scene.instantiate()
	if node.has_method("post_instantiate"):
		node.post_instantiate(entity_id, spawn_data)
	return node
