## Manages entity IDs using generational index.
##
## Each entity_id is a 30-bit integer:
## - bits 0..21 (22 bits): index into the generations array (~4M slots)
## - bits 22..29 (8 bits): generation (256 cycles per slot)
##
## When an entity is destroyed, its generation is incremented.
## Recycled IDs get the same index but a new generation,
## so old references are detected as invalid.
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


## Creates a new entity and returns its ID.
##
## Reuses indices from destroyed entities (free list) when
## available. Otherwise, expands the generations array.
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


## Forces creation of an entity with a specific ID.
## Used by the Replicator to recreate entities on the client
## with the same ID they were created with on the server.
func force_create(entity: int) -> void:
	var index = entity & INDEX_MASK
	var gen = (entity >> GEN_SHIFT) & GEN_MASK
	while index >= _generations.size():
		_generations.append(0)
	_generations[index] = gen & GEN_MASK
	_living_count += 1


## Checks if an entity still exists (has not been destroyed).
##
## Compares the stored generation with the generation in the ID.
## If destroyed and recreated, the generation will differ.
func exists(entity: int) -> bool:
	var index = _unpack_index(entity)
	var gen = _unpack_gen(entity)
	return index < _generations.size() and _generations[index] == gen


## Destroys an entity: increments the generation and adds
## the index to the free list for future reuse.
func destroy(entity: int) -> void:
	assert(exists(entity), "destroying non-existent entity")
	var index = _unpack_index(entity)
	_generations[index] = (_generations[index] + 1) & GEN_MASK
	_free_list.append(index)
	_living_count -= 1


## Number of currently living entities.
func living_count() -> int:
	return _living_count


## Packs index and generation into a single 30-bit integer.
func _pack(index: int, generation: int) -> int:
	return (generation << GEN_SHIFT) | index


## Extracts the index (lower 22 bits) from the entity_id.
func _unpack_index(entity: int) -> int:
	return entity & INDEX_MASK


## Extracts the generation (next 8 bits) from the entity_id.
func _unpack_gen(entity: int) -> int:
	return (entity >> GEN_SHIFT) & GEN_MASK
