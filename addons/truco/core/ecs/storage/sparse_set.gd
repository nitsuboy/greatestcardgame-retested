## Stores components of the same type using a Sparse Set.
##
## O(1) lookup with cache-friendly iteration.
## Composed of three parallel arrays:
## - _sparse:  entity_index (= entity_id & INDEX_MASK) → index in _dense (or -1 if absent)
## - _dense:   entity_ids in insertion order
## - _data:    components in the same order as _dense
##
## Removal uses swap-with-last to avoid shifting:
## copies the last element to the removed position and resizes.
class_name SparseSet
extends RefCounted

const INDEX_MASK = (1 << 22) - 1

var _sparse: PackedInt32Array
var _dense: PackedInt32Array
var _data: Array[Resource]


func _init(capacity: int = 64) -> void:
	_sparse.resize(capacity)
	_sparse.fill(-1)


## Ensures _sparse has room for the entity_id.
## Resizes in blocks of 64 slots, filling new ones with -1.
func ensure_space(entity: int) -> void:
	var e = entity & INDEX_MASK
	if e >= _sparse.size():
		var old = _sparse.size()
		_sparse.resize(e + 64)
		for i in range(old, _sparse.size()):
			_sparse[i] = -1


## Returns true if the entity has this component in storage.
##
## Checks three conditions:
## 1. entity_index (entity_id & INDEX_MASK) is within sparse range
## 2. sparse[entity_index] >= 0 (valid dense index)
## 3. dense[index] == entity (consistency — prevents false positives
##    after an entity is destroyed and the ID is reused with a different generation)
func has(entity: int) -> bool:
	var e = entity & INDEX_MASK
	if e >= _sparse.size():
		return false
	var idx = _sparse[e]
	return idx >= 0 and idx < _dense.size() and _dense[idx] == entity


## Adds a component to an entity.
## O(1) amortized — appends to dense + updates sparse.
func add(entity: int, component: Resource) -> void:
	ensure_space(entity)
	assert(not has(entity), "entity already has this component")
	var idx = _dense.size()
	_dense.append(entity)
	_data.append(component)
	_sparse[entity & INDEX_MASK] = idx


## Returns the entity's component. O(1).
func get_(entity: int) -> Resource:
	assert(has(entity), "entity does not have this component")
	return _data[_sparse[entity & INDEX_MASK]]


## Removes the component from an entity. O(1).
##
## Swap-with-last: copies the last dense element to the
## removed position, then resizes. Avoids shifting
## all subsequent elements.
## Uses entity_index (entity_id & INDEX_MASK) for sparse lookups.
func remove(entity: int) -> void:
	assert(has(entity), "entity does not have this component")
	var e = entity & INDEX_MASK
	var idx = _sparse[e]
	var last = _dense.size() - 1

	if idx != last:
		var last_entity = _dense[last]
		_dense[idx] = last_entity
		_data[idx] = _data[last]
		_sparse[last_entity & INDEX_MASK] = idx

	_dense.resize(last)
	_data.resize(last)
	_sparse[e] = -1


## Returns all entities that have this component (dense array).
## Used by the Query system for iteration.
func get_all_entities() -> PackedInt32Array:
	return _dense


## Returns all components of this type (aligned with get_all_entities).
func get_all_data() -> Array[Resource]:
	return _data


## Number of entities with this component.
func size() -> int:
	return _dense.size()


## Removes all entities and components from this storage.
func clear() -> void:
	_dense.clear()
	_data.clear()
	_sparse.fill(-1)
