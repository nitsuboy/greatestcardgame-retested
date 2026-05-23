# GdUnit generated TestSuite
class_name SparseSetTests
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

const __source = "res://addons/truco/core/ecs/storage/sparse_set.gd"

var sparse: SparseSet

func before_test() -> void:
	sparse = SparseSet.new()

func test_add_and_has() -> void:
	sparse.add(0, DummyComponent.new())
	assert(sparse.has(0))

func test_has_non_existent() -> void:
	assert(!sparse.has(0))

func test_has_beyond_sparse_range() -> void:
	assert(!sparse.has(999))

func test_get_returns_component() -> void:
	
	var comp = DummyComponent.new()
	sparse.add(0, comp)
	assert(sparse.get_(0) == comp)

func test_size() -> void:
	assert(sparse.size() == 0)
	sparse.add(0, DummyComponent.new())
	assert(sparse.size() == 1)
	sparse.add(1, DummyComponent.new())
	assert(sparse.size() == 2)

func test_remove_reduces_size() -> void:
	sparse.add(0, DummyComponent.new())
	sparse.remove(0)
	assert(sparse.size() == 0)
	assert(!sparse.has(0))

func test_remove_swap_with_last_preserves_order() -> void:
	sparse.add(0, DummyComponent.new())
	sparse.add(1, DummyComponent.new())
	sparse.add(2, DummyComponent.new())
	sparse.remove(0)
	assert(sparse.has(1))
	assert(sparse.has(2))
	assert(!sparse.has(0))
	assert(sparse.size() == 2)

func test_remove_last_entity() -> void:
	sparse.add(0, DummyComponent.new())
	sparse.remove(0)
	assert(sparse.size() == 0)

func test_remove_middle_swaps_correctly() -> void:
	var comp0 = DummyComponent.new()
	var comp1 = DummyComponent.new()
	var comp2 = DummyComponent.new()
	sparse.add(0, comp0)
	sparse.add(1, comp1)
	sparse.add(2, comp2)
	sparse.remove(1)
	assert(sparse.has(0))
	assert(sparse.has(2))
	assert(!sparse.has(1))
	var entities = sparse.get_all_entities()
	assert(entities.size() == 2)

func test_get_all_entities_and_data_aligned() -> void:
	var comp0 = DummyComponent.new()
	var comp2 = DummyComponent.new()
	sparse.add(0, comp0)
	sparse.add(2, comp2)
	var entities = sparse.get_all_entities()
	var data = sparse.get_all_data()
	assert(entities.size() == 2)
	assert(data.size() == 2)
	assert(entities[0] == 0)
	assert(data[0] == comp0)
	assert(entities[1] == 2)
	assert(data[1] == comp2)

func test_ensure_space_grows() -> void:
	sparse.add(200, DummyComponent.new())
	assert(sparse.has(200))
	assert(sparse.size() == 1)

func test_clear() -> void:
	sparse.add(0, DummyComponent.new())
	sparse.add(1, DummyComponent.new())
	sparse.clear()
	assert(sparse.size() == 0)
	assert(!sparse.has(0))
	assert(!sparse.has(1))

func test_duplicate_add_asserts() -> void:
	sparse.add(0, DummyComponent.new())
	assert_error(func(): sparse.add(0, DummyComponent.new()))
