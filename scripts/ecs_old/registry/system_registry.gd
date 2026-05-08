class_name SystemRegistry
extends RefCounted

static var _all_systems: Dictionary[Script, bool] = {}


## Registers a system script in the system registry
static func register_system(system: Script) -> void:
	if _all_systems.has(system):
		return

	_all_systems[system] = true


## Returns all scripts of all systems
static func get_all_systems() -> Array[Script]:
	return _all_systems.keys()
