class_name SparseSet
extends RefCounted

var _sparse: PackedInt32Array  # entity_id → dense_index ou -1
var _dense: PackedInt32Array  # entity_ids
var _data: Array[Resource]  # componentes, paralelo ao _dense


func _init(capacity: int = 64) -> void:
	_sparse.resize(capacity)
	_sparse.fill(-1)


func ensure_space(entity: int) -> void:
	if entity >= _sparse.size():
		var old = _sparse.size()
		_sparse.resize(entity + 64)
		for i in range(old, _sparse.size()):
			_sparse[i] = -1


func has(entity: int) -> bool:
	if entity >= _sparse.size():
		return false
	var idx = _sparse[entity]
	return idx >= 0 and idx < _dense.size() and _dense[idx] == entity


func add(entity: int, component: Resource) -> void:
	ensure_space(entity)
	assert(not has(entity), "entity already has this component")
	var idx = _dense.size()
	_dense.append(entity)
	_data.append(component)
	_sparse[entity] = idx


func get_(entity: int) -> Resource:
	assert(has(entity), "entity does not have this component")
	return _data[_sparse[entity]]


func remove(entity: int) -> void:
	assert(has(entity), "entity does not have this component")
	var idx = _sparse[entity]
	var last = _dense.size() - 1

	if idx != last:
		var last_entity = _dense[last]
		_dense[idx] = last_entity
		_data[idx] = _data[last]
		_sparse[last_entity] = idx

	_dense.resize(last)
	_data.resize(last)
	_sparse[entity] = -1


func get_all_entities() -> PackedInt32Array:
	return _dense


func get_all_data() -> Array[Resource]:
	return _data


func size() -> int:
	return _dense.size()


func clear() -> void:
	_dense.clear()
	_data.clear()
	_sparse.fill(-1)
