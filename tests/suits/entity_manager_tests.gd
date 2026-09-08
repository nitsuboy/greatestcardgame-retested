# GdUnit generated TestSuite
class_name  EntityManagerTests
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

const __source = "res://addons/truco/core/ecs/storage/entity_manager.gd"

var em: EntityManager

func before_test() -> void:
	em = EntityManager.new()
	

func test_create_returns_increasing_ids() -> void:
	var e1 = em.create()
	var e2 = em.create()
	assert(e1 != e2)
	assert(e1 >= 0)
	assert(e2 > e1)

func test_exists_after_create() -> void:
	var e = em.create()
	assert(em.exists(e))

func test_not_exists_after_destroy() -> void:
	var e = em.create()
	em.destroy(e)
	assert(!em.exists(e))

func test_living_count() -> void:
	assert(em.living_count() == 0)
	em.create()
	assert(em.living_count() == 1)
	em.create()
	assert(em.living_count() == 2)
	em.destroy(em.create())
	assert(em.living_count() == 2)

func test_destroy_decrements_living_count() -> void:
	var e = em.create()
	em.destroy(e)
	assert(em.living_count() == 0)

func test_free_list_reuses_index() -> void:
	var e1 = em.create()
	em.destroy(e1)
	var e2 = em.create()
	var idx1 = e1 & ((1 << 22) - 1)
	var idx2 = e2 & ((1 << 22) - 1)
	assert(idx1 == idx2)
	assert(e1 != e2)

func test_old_id_invalid_after_destroy_and_recreate() -> void:
	var e1 = em.create()
	em.destroy(e1)
	var e2 = em.create()
	assert(em.exists(e2))
	assert(!em.exists(e1))

func test_force_create() -> void:
	var custom_id = (5 << 22) | 10
	em.force_create(custom_id)
	assert(em.exists(custom_id))
	assert(em.living_count() == 1)

func test_force_create_reuses_existing_generation_slot() -> void:
	var e = em.create()
	em.destroy(e)
	var idx = e & ((1 << 22) - 1)
	var new_id = (7 << 22) | idx
	em.force_create(new_id)
	assert(em.exists(new_id))
	assert(em.living_count() == 1)

func test_destroy_nonexistent_asserts() -> void:	
	assert_error(func(): em.destroy(999))
