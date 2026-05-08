class_name World
extends RefCounted

var entities: EntityManager
var events: EventBus

var _storages: Dictionary[Script, SparseSet] = {}


func _init() -> void:
	entities = EntityManager.new()
	events = EventBus.new()


# --- Entity ---


func create_entity() -> int:
	return entities.create()


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


func storage_size(type: Script) -> int:
	return _storages[type].size() if _storages.has(type) else 0


func get_storage(type: Script) -> SparseSet:
	return _storages.get(type)


# --- Query ---


func query(all: Array[Script] = []) -> Query:
	return Query.new(self, all)
