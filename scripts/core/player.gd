@tool
class_name Player
extends DropZone


func post_instantiate(id: int = -1, _spawn_data: Dictionary = {}) -> void:
	entity = Entity.new(id)
	var nc: NodeComponent = NodeComponent.new()
	nc.node = self
	entity.components.append(nc)

	for c: Component in components:
		var comp = c.duplicate(true)
		if "hand" in comp:
			comp.hand = get_child(0)
			comp.debug = get_child(1)
		entity.components.append(comp)

	for k in _spawn_data.keys():
		match k:
			"transform":
				self.transform = (
					Net.game.get_point_on_path(_spawn_data["transform"])
					* Transform2D(PI, Vector2.ZERO)
				)
			"scale":
				self.scale = _spawn_data["scale"]
			_:
				pass
