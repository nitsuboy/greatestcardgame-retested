class_name EntityRegistry
extends RefCounted

static var _next_entity_uid: int = 0
static var _all_entities: Dictionary[int,Entity] = {}
static var _current_entities: Dictionary[int,Entity] = {}


static func _calculate_next_entity_uid() -> int:
	while _all_entities.has(_next_entity_uid):
		_next_entity_uid += 1
	return _next_entity_uid


## adds a new entity to the registry
static func add_new_entity() -> void:
	var entity = Entity.new()
	entity.uid = _calculate_next_entity_uid()
	_next_entity_uid += 1
	_all_entities[entity.uid] = entity
	_current_entities[entity.uid] = entity


## adds a new entity to the registry with a pre-calculated uid
static func add_new_entity_with_uid(uid: int) -> void:
	if _all_entities.has(uid):
		push_error("Tentando criar entidade com uid que já pertence a outra entidade")
		return
	
	var entity = Entity.new()
	entity.uid = uid
	_all_entities[entity.uid] = entity
	_current_entities[entity.uid] = entity


## deletes a entity from the registry
static func delete_entity(entity_uid: int) -> void:
	var entity = get_entity(entity_uid)
	
	var ev = EntityDeleteEvent.new(entity)
	EventSystem.iniciar_evento_local(entity, ev)
	EventSystem.iniciar_evento_global(ev)
	
	for comp in EntitySystem.get_all_comps(entity):
		EntitySystem.remove_comp_object(entity, comp)
	
	_current_entities.erase(entity_uid)
	entity.deleted = true


## returns the entity with a specified entity_uid, if the entity was deleted, it returns null
static func get_entity(entity_uid: int) -> Entity:
	return _current_entities.get(entity_uid)
