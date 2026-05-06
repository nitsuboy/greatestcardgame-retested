@tool
class_name Player
extends DropZone


func post_instantiate(id: int = -1, _spawn_data: Dictionary = {}) -> void:
	if id == -1:
		id = EntityRegistry.calculate_next_entity_uid()
	EntityRegistry.add_new_entity_with_uid(id)
	entity = EntityRegistry.get_entity(id)

	EntitySystem.ensure_comp(entity, NodeComponent).node = self

	for c: Component in components:
		var comp = c.duplicate(true)
		if comp is PlayableComponent:
			comp.debug.text = str(_spawn_data["name"])
			comp.debug.rotation = -rotation
			comp.hand.block_hand(true, true)
		if "hand" in comp:
			comp.hand = get_child(0)
			comp.debug = get_child(1)
		ComponentRegistry.add_component_to_entity(id, comp)

	for k in _spawn_data.keys():
		match k:
			"transform":
				self.transform = _spawn_data["transform"]
			"scale":
				self.scale = _spawn_data["scale"]
			_:
				pass
