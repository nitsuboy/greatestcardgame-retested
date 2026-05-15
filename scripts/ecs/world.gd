class_name World
extends RefCounted

var entities: EntityManager
var events: EventBus

var _storages: Dictionary[Script, SparseSet] = {}
var _query_cache: Dictionary = {}


func _init() -> void:
	entities = EntityManager.new()
	events = EventBus.new()


# --- Entity ---


func create_entity() -> int:
	var entity_id: int = entities.create()
	events.on_entity_created.emit(entity_id)
	return entity_id


func delete_entity(entity: int) -> void:
	assert(entities.exists(entity), "entity does not exist")
	for storage in _storages.values():
		if storage.has(entity):
			storage.remove(entity)
	entities.destroy(entity)
	events.on_entity_destroyed.emit(entity)


# --- Component ---


func add_component(entity: int, component: Resource) -> void:
	assert(entities.exists(entity), "entity does not exist")
	var type = component.get_script()
	if not _storages.has(type):
		_storages[type] = SparseSet.new()
	_storages[type].add(entity, component)
	events.on_component_added.emit(entity, type)


func remove_component(entity: int, type: Script) -> void:
	assert(entities.exists(entity), "entity does not exist")
	assert(has_component(entity, type), "entity does not have this component")
	_storages[type].remove(entity)
	events.on_component_removed.emit(entity, type)


func get_component(entity: int, type: Script) -> Resource:
	assert(entities.exists(entity), "entity does not exist")
	return _storages[type].get_(entity)


func has_component(entity: int, type: Script) -> bool:
	return _storages.has(type) and _storages[type].has(entity)


func get_all_components(entity: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for type in _storages:
		if not _storages[type].has(entity):
			continue
		var comp: Component = _storages[type].get_(entity)
		if not comp.should_serialize():
			continue
		result.append({"entity": entity, "type": type.resource_path, "data": comp.to_dict()})
	return result


func storage_size(type: Script) -> int:
	return _storages[type].size() if _storages.has(type) else 0


func get_storage(type: Script) -> SparseSet:
	return _storages.get(type)


# --- Query ---


func query(all: Array[Script] = []) -> Query:
	var key = PackedStringArray()
	for s in all:
		key.append(s.resource_path)
	var k = "\n".join(key)
	if not _query_cache.has(k):
		_query_cache[k] = Query.new(self, all)
	return _query_cache[k]


# --- Systems ---

var _systems: Dictionary[Script, SystemNode] = {}


func register_system(sys: SystemNode, type: Script) -> void:
	_systems[type] = sys


func get_system(type: Script) -> SystemNode:
	return _systems.get(type)
