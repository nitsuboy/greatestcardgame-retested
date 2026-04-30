class_name PrototypeSpawner
extends Node

signal prototype_spawned(prototype_id: String, entity_id: int, node: Node)


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

	var entity_id = Entity.calculate_next_id()
	node.post_instantiate(entity_id, marker.spawn_data)
	marker.initialized = true
	return node


func spawn(prototype_id: String, parent: Node, spawn_data: Dictionary = {}) -> Node:
	if not multiplayer.is_server():
		push_error("PrototypeSpawner: only server can spawn prototypes")
		return null

	if not PrototypeRegistry.has(prototype_id):
		push_error("PrototypeSpawner: prototype '%s' not registered" % prototype_id)
		return null

	var entity_id = Entity.calculate_next_id()
	var node = _instantiate(prototype_id, entity_id, spawn_data)
	parent.add_child(node)
	_rpc_spawn.rpc(prototype_id, entity_id, spawn_data, parent.get_path())
	prototype_spawned.emit(prototype_id, entity_id, node)
	return node


@rpc("call_local")
func _rpc_spawn(
	prototype_id: String, entity_id: int, spawn_data: Dictionary, parent_path: NodePath
) -> void:
	var node = _instantiate(prototype_id, entity_id, spawn_data)
	var parent = get_node(parent_path)
	parent.add_child(node)
	prototype_spawned.emit(prototype_id, entity_id, node)


static func _instantiate(prototype_id: String, entity_id: int, spawn_data: Dictionary) -> Node:
	var scene = PrototypeRegistry.get_scene(prototype_id)
	var node = scene.instantiate()
	if node.has_method("post_instantiate"):
		node.post_instantiate(entity_id, spawn_data)
	return node
