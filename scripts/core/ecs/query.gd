## Itera entidades que possuem um conjunto específico de componentes.
##
## Otimização: encontra o tipo de componente com a MENOR quantidade de
## entidades e itera apenas ele, verificando se cada entidade também
## possui os demais componentes obrigatórios. Isso minimiza o número
## de checks de has_component.
class_name Query
extends RefCounted

var _archetypes: Array[Script]
var _world: World


func _init(world: World, all: Array[Script]) -> void:
	_world = world
	_archetypes = all


## Executa callback para cada entidade que possui TODOS os componentes.
##
## O callback recebe (entity_id: int, components: Array[Resource]).
## A ordem dos componentes no array segue a ordem dos tipos passados
## no construtor da Query.
func for_each(callback: Callable) -> void:
	if _archetypes.is_empty():
		return

	# Encontra o storage com menos entidades para iterar
	var smallest_type = _archetypes[0]
	var smallest_size = _world.storage_size(smallest_type)
	for type in _archetypes:
		var s = _world.storage_size(type)
		if s < smallest_size:
			smallest_size = s
			smallest_type = type

	var storage = _world.get_storage(smallest_type)
	if storage == null:
		return

	var entities = storage.get_all_entities()
	var data = storage.get_all_data()

	var tmp: Array[Resource] = []
	tmp.resize(_archetypes.size())

	# Para cada entidade no menor storage, verifica se possui
	# os demais componentes obrigatórios
	for i in entities.size():
		var entity = entities[i]
		tmp[0] = data[i]
		var matched = true
		for j in range(1, _archetypes.size()):
			if _world.has_component(entity, _archetypes[j]):
				tmp[j] = _world.get_component(entity, _archetypes[j])
			else:
				matched = false
				break
		if matched:
			callback.call(entity, tmp)
