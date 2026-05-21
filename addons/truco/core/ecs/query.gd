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

	# Find the storage with the fewest entities to iterate
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

	# For each entity in the smallest storage, check it has
	# all other required components
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
