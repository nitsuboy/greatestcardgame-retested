## Base class for all ECS components.
##
## Components are Resources, which enables automatic serialization
## and compatibility with Godot's resource system (can be saved as .tres).
##
## To create a new component, extend this class and declare
## @export or public properties (no _ prefix):
##     class_name MyComponent extends Component
##     @export var health: int
##
## Properties with _ prefix are ignored by to_dict/from_dict.
class_name Component
extends Resource


## Controls whether this component is included in Replicator
## serialization. Return false for local components that
## should not be synced over the network (e.g. NodeRef).
func should_serialize() -> bool:
	return true


## Converts the component's public properties into a Dictionary
## for network transmission.
##
## Supports: int, float, String, bool, Vector2 (as {"x":, "y":}).
## Complex types are converted with str().
func to_dict() -> Dictionary:
	var dict = {}
	var props = get_property_list()
	for prop in props:
		var name = prop["name"]
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
				dict[name] = str(value)
	return dict


## Restores the component's properties from a Dictionary.
## Inverse operation of to_dict().
func from_dict(data: Dictionary) -> void:
	for key in data.keys():
		if key in self:
			var value = data[key]
			if typeof(value) == TYPE_DICTIONARY and value.has("x"):
				set(key, Vector2(value["x"], value["y"]))
			else:
				set(key, value)
