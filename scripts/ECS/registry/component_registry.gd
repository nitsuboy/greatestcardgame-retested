class_name ComponentRegistry
extends RefCounted

static var _all_components: Dictionary[StringName,Script] = {}


static func get_component(type: StringName) -> Script:
	return _all_components.get(type)


static func get_all_component() -> Dictionary:
	return _all_components


static func delete_component(type: StringName) -> bool:
	return _all_components.erase(type)
