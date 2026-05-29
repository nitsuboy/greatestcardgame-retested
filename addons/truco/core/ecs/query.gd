## Iterates entities that have a specific set of components.
##
## Optimization: finds the component type with the FEWEST entities
## and iterates only that one, checking if each entity also has
## the other required components. This minimizes the number of
## has_component checks.
class_name Query
extends RefCounted

var _archetypes: Array[Script]
var _world: World


func _init(world: World, all: Array[Script]) -> void:
	_world = world
	_archetypes = all


## Runs a callback for each entity that has ALL components.
##
## The callback receives (entity_id: int, components: Array[Resource]).
## Component order follows the type order passed in the constructor.
func for_each(callback: Callable) -> void:
	if _archetypes.is_empty():
		return

	for i in _archetypes:
		print(i)

	# Find the storage with the fewest entities to iterate
	var smallest_type = _archetypes[0]
	var smallest_size = _world.storage_size(smallest_type)
	var smallest_index = 0
	for idx in range(_archetypes.size()):
		var type = _archetypes[idx]
		var s = _world.storage_size(type)
		if s < smallest_size:
			smallest_index = idx
			smallest_size = s
			smallest_type = type

	var storage = _world.get_storage(smallest_type)
	if storage == null:
		return

	var entities = storage.get_all_entities()
	var data = storage.get_all_data()

	var tmp: Array[Resource] = []
	tmp.resize(_archetypes.size())

	# For each entity in the smallest storage, check it has
	# all other required components
	for i in entities.size():
		var entity = entities[i]
		tmp[smallest_index] = data[i]
		var matched = true
		for j in range(0, _archetypes.size()):
			if j == smallest_index:
				continue
			if _world.has_component(entity, _archetypes[j]):
				tmp[j] = _world.get_component(entity, _archetypes[j])
			else:
				matched = false
				break
		if matched:
			callback.call(entity, tmp)
