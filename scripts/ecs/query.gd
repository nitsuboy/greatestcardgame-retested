class_name Query
extends RefCounted

var _archetypes: Array[Script]  # componentes obrigatórios
var _world: World


func _init(world: World, all: Array[Script]) -> void:
	_world = world
	_archetypes = all


func has_archetypes() -> bool:
	var smallest_type: Script = _archetypes[0]
	var smallest_size: int = _world.storage_size(smallest_type)

	for type in _archetypes:
		var s = _world.storage_size(type)
		if s < smallest_size:
			smallest_size = s
			smallest_type = type

	var storage = _world.get_storage(smallest_type)
	if storage == null:
		return false

	var entities = storage.get_all_entities()
	var data = storage.get_all_data()

	for i in entities.size():
		var entity = entities[i]
		var comps: Array[Resource] = [data[i]]

		var matched = true
		for j in range(1, _archetypes.size()):
			if _world.has_component(entity, _archetypes[j]):
				comps.append(_world.get_component(entity, _archetypes[j]))
			else:
				matched = false
				break

		if matched:
			return true
	return false


func for_each(callback: Callable) -> void:
	if _archetypes.is_empty():
		return

	# seleciona o sparse_set com MENOS entidades
	var smallest_type: Script = _archetypes[0]
	var smallest_size: int = _world.storage_size(smallest_type)

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

	for i in entities.size():
		var entity = entities[i]
		var comps: Array[Resource] = [data[i]]

		var matched = true
		for j in range(1, _archetypes.size()):
			if _world.has_component(entity, _archetypes[j]):
				comps.append(_world.get_component(entity, _archetypes[j]))
			else:
				matched = false
				break

		if matched:
			callback.call(entity, comps)
