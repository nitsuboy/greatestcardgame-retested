class_name PrototypeRegistry
extends RefCounted

static var _prototypes: Dictionary[String, PrototypeDef] = {}


static func register(id: String, scene: PackedScene, spawn_data_fn: Callable = Callable()) -> void:
	if _prototypes.has(id):
		push_warning("PrototypeRegistry: prototype '%s' already registered")
		return
	_prototypes[id] = PrototypeDef.new(scene, spawn_data_fn)


static func get_scene(id: String) -> PackedScene:
	var def = _prototypes.get(id)
	if not def:
		push_error("PrototypeRegistry: prototype '%s' not found" % id)
		return null
	return def.scene


static func get_spawn_data_fn(id: String) -> Callable:
	var def = _prototypes.get(id)
	if not def:
		return Callable()
	return def.spawn_data_fn


static func has(id: String) -> bool:
	return _prototypes.has(id)


static func get_all_ids() -> Array[String]:
	return _prototypes.keys()


class PrototypeDef:
	var scene: PackedScene
	var spawn_data_fn: Callable

	func _init(_scene: PackedScene, _spawn_data_fn: Callable) -> void:
		scene = _scene
		spawn_data_fn = _spawn_data_fn
