@abstract class_name Component
extends Resource


func should_serialize() -> bool:
	return true


func to_dict() -> Dictionary:
	var dict = {}
	var props = get_property_list()
	for prop in props:
		var name = prop["name"]
		# Ignorar propriedades herdadas ou internas
		if (
			name.begins_with("_")
			or (
				name
				in [
					"script",
					"resource_local_to_scene",
					"resource_name",
					"resource_scene_unique_id",
					"resource_path"
				]
			)
		):
			continue

		var value = get(name)
		# Converter tipos Godot para serializável
		match prop["type"]:
			TYPE_NIL:
				continue
			TYPE_VECTOR2:
				dict[name] = {"x": value.x, "y": value.y}
			TYPE_INT, TYPE_FLOAT, TYPE_STRING:
				dict[name] = value
			TYPE_BOOL:
				dict[name] = value
			_:
				# Objects complexos precisam manual
				dict[name] = str(value)
	return dict


func from_dict(data: Dictionary) -> void:
	for key in data.keys():
		if key in self:
			var value = data[key]
			if typeof(value) == TYPE_DICTIONARY and value.has("x"):
				set(key, Vector2(value["x"], value["y"]))
			else:
				set(key, value)
