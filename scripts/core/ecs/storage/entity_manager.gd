class_name EntityManager
extends RefCounted

const INDEX_BITS: int = 22
const GEN_BITS: int = 8
const INDEX_MASK: int = (1 << INDEX_BITS) - 1
const GEN_MASK: int = (1 << GEN_BITS) - 1
const GEN_SHIFT: int = INDEX_BITS

var _generations: PackedInt32Array
var _free_list: PackedInt32Array
var _living_count: int = 0


func create() -> int:
	var index: int
	if _free_list.size() > 0:
		index = _free_list[_free_list.size() - 1]
		_free_list.resize(_free_list.size() - 1)
	else:
		index = _generations.size()
		_generations.append(0)

	_generations[index] = _generations[index] & GEN_MASK
	_living_count += 1
	return _pack(index, _generations[index])


func force_create(entity: int) -> void:
	var index = entity & INDEX_MASK
	var gen = (entity >> GEN_SHIFT) & GEN_MASK
	while index >= _generations.size():
		_generations.append(0)
	_generations[index] = gen & GEN_MASK
	_living_count += 1


func exists(entity: int) -> bool:
	var index = _unpack_index(entity)
	var gen = _unpack_gen(entity)
	return index < _generations.size() and _generations[index] == gen


func destroy(entity: int) -> void:
	assert(exists(entity), "destroying non-existent entity")
	var index = _unpack_index(entity)
	_generations[index] = (_generations[index] + 1) & GEN_MASK
	_free_list.append(index)
	_living_count -= 1


func living_count() -> int:
	return _living_count


func _pack(index: int, generation: int) -> int:
	return (generation << GEN_SHIFT) | index


func _unpack_index(entity: int) -> int:
	return entity & INDEX_MASK


func _unpack_gen(entity: int) -> int:
	return (entity >> GEN_SHIFT) & GEN_MASK
