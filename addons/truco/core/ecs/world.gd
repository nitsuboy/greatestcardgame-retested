## Central ECS orchestrator.
##
## Facade managing entities, components, queries and systems.
## Holds one SparseSet per component type, keyed by the exact Script.
##
## CRITICAL: Storage is keyed by component.get_script(), which returns the
## exact class. Component inheritance does NOT work — if you add a subclass
## component, has_component with the parent class returns false.
## Use composition (multiple components on the same entity).
class_name World
extends RefCounted

## ECS entity manager.
var entities: EntityManager
## Event bus for ECS and game signals.
var events: EventBus

var _storages: Dictionary[Script, SparseSet] = {}
var _query_cache: Dictionary = {}
var _systems: Dictionary[Script, SystemNode] = {}


func _init() -> void:
	entities = EntityManager.new()
	events = EventBus.new()


# --------------------------------------------------------------------------
# Entity API
# --------------------------------------------------------------------------


## Creates a new entity and returns its ID.
## Emits on_entity_created.
func create_entity() -> int:
	var entity_id: int = entities.create()
	events.on_entity_created.emit(entity_id)
	return entity_id


## Removes the entity and all its components.
## Emits on_entity_destroyed.
func delete_entity(entity: int) -> void:
	assert(entities.exists(entity), "entity does not exist")
	for storage in _storages.values():
		if storage.has(entity):
			storage.remove(entity)
	entities.destroy(entity)
	events.on_entity_destroyed.emit(entity)


# --------------------------------------------------------------------------
# Component API
# --------------------------------------------------------------------------


## Adds a component to an entity.
##
## Creates the SparseSet for this component type if it does not exist yet.
## Emits on_component_added with the component's Script.
func add_component(entity: int, component: Resource) -> void:
	assert(entities.exists(entity), "entity does not exist")
	var type = component.get_script()
	if not _storages.has(type):
		_storages[type] = SparseSet.new()
	_storages[type].add(entity, component)
	events.on_component_added.emit(entity, type)


## Removes a component from an entity by its type.
## Emits on_component_removed.
func remove_component(entity: int, type: Script) -> void:
	assert(entities.exists(entity), "entity does not exist")
	assert(has_component(entity, type), "entity does not have this component")
	_storages[type].remove(entity)
	events.on_component_removed.emit(entity, type)


## Returns the component of a specific type.
##
## CRASHES if the storage for this type does not exist. Always use
## has_component as a guard before calling this method.
func get_component(entity: int, type: Script) -> Resource:
	assert(entities.exists(entity), "entity does not exist")
	return _storages[type].get_(entity)


## Checks if the entity has a component of a given type.
##
## Safe even if the storage for this type was never created
## (returns false instead of crashing).
func has_component(entity: int, type: Script) -> bool:
	return _storages.has(type) and _storages[type].has(entity)


## Returns all serializable components of an entity.
##
## Used by the Replicator to generate sync batches.
## Skips components with should_serialize() == false (e.g. NodeRef).
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


## Number of entities with a given component type.
func storage_size(type: Script) -> int:
	return _storages[type].size() if _storages.has(type) else 0


## Returns the SparseSet for a component type (or null).
func get_storage(type: Script) -> SparseSet:
	return _storages.get(type)


# --------------------------------------------------------------------------
# Query API
# --------------------------------------------------------------------------


## Creates (or reuses from cache) a Query for entities that have
## all the specified component types.
##
## Queries are cached by concatenated resource_path of the scripts.
## The same set of types always returns the same Query instance.
func query(all: Array[Script] = []) -> Query:
	var key = PackedStringArray()
	for s in all:
		key.append(s.resource_path)
	var k = "\n".join(key)
	if not _query_cache.has(k):
		_query_cache[k] = Query.new(self, all)
	return _query_cache[k]


# --------------------------------------------------------------------------
# System API
# --------------------------------------------------------------------------


## Registers a system for access via get_system.
## Called by any object with access to the world.
func register_system(sys: SystemNode, type: Script) -> void:
	_systems[type] = sys


## Returns a registered system by its Script.
## Used to access other systems from within a system.
func get_system(type: Script) -> SystemNode:
	return _systems.get(type)
