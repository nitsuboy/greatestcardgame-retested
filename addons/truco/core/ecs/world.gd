## Orquestrador central do ECS.
##
## Facade que gerencia entidades, componentes, queries e sistemas.
## Mantém um SparseSet por tipo de componente, chaveado pelo Script exato.
##
## CRÍTICO: O storage é chaveado por component.get_script(), que retorna a
## classe exata. Herança entre componentes NÃO funciona — se você adicionar
## um componente de uma subclasse, has_component com a classe pai retorna false.
## Use composição (múltiplos componentes na mesma entidade).
class_name World
extends RefCounted

var entities: EntityManager
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


## Cria uma nova entidade e retorna seu ID.
## Emite on_entity_created.
func create_entity() -> int:
	var entity_id: int = entities.create()
	events.on_entity_created.emit(entity_id)
	return entity_id


## Remove a entidade e todos os seus componentes.
## Emite on_entity_destroyed.
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


## Adiciona um componente a uma entidade.
##
## Cria o SparseSet para este tipo de componente se ainda não existir.
## Emite on_component_added com o Script do componente.
func add_component(entity: int, component: Resource) -> void:
	assert(entities.exists(entity), "entity does not exist")
	var type = component.get_script()
	if not _storages.has(type):
		_storages[type] = SparseSet.new()
	_storages[type].add(entity, component)
	events.on_component_added.emit(entity, type)


## Remove um componente de uma entidade pelo tipo.
## Emite on_component_removed.
func remove_component(entity: int, type: Script) -> void:
	assert(entities.exists(entity), "entity does not exist")
	assert(has_component(entity, type), "entity does not have this component")
	_storages[type].remove(entity)
	events.on_component_removed.emit(entity, type)


## Retorna o componente de um tipo específico.
##
## CRASH se o storage do tipo não existir. Sempre usar has_component
## como guarda antes de chamar este método.
func get_component(entity: int, type: Script) -> Resource:
	assert(entities.exists(entity), "entity does not exist")
	return _storages[type].get_(entity)


## Verifica se a entidade possui um componente de determinado tipo.
##
## Seguro mesmo que o storage do tipo nunca tenha sido criado
## (retorna false em vez de crashar).
func has_component(entity: int, type: Script) -> bool:
	return _storages.has(type) and _storages[type].has(entity)


## Retorna todos os componentes serializáveis de uma entidade.
##
## Usado pelo Replicator para gerar o batch de sincronização.
## Pula componentes com should_serialize() == false (ex: NodeRef).
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


## Número de entidades com um determinado tipo de componente.
func storage_size(type: Script) -> int:
	return _storages[type].size() if _storages.has(type) else 0


## Retorna o SparseSet de um tipo de componente (ou null).
func get_storage(type: Script) -> SparseSet:
	return _storages.get(type)


# --------------------------------------------------------------------------
# Query API
# --------------------------------------------------------------------------


## Cria (ou reusa do cache) uma Query para entidades que possuem
## todos os tipos de componente especificados.
##
## A query é cacheadas por resource_path dos scripts concatenados.
## Mesmo conjunto de tipos sempre retorna a mesma instância de Query.
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


## Registra um sistema para acesso via get_system.
## Chamado pelo WorldRunner durante _ready.
func register_system(sys: SystemNode, type: Script) -> void:
	_systems[type] = sys


## Retorna um sistema registrado pelo seu Script.
## Usado por sistemas que precisam chamar métodos de outros sistemas.
func get_system(type: Script) -> SystemNode:
	return _systems.get(type)
