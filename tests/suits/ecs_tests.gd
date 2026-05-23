# GdUnit generated TestSuite
class_name ECSTests
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = "res://addons/truco/core/ecs/world.gd"

var runner: GdUnitSceneRunner
var worldruner: WorldRunner

func before_test() -> void:
	runner = scene_runner("res://tests/worldrunnertest.tscn")
	worldruner = runner.invoke("find_child","WorldRunner")

func test_world_creation() -> void:
	assert(worldruner.world)

func test_systems_added() -> void:
	var world: World = worldruner.world
	assert(worldruner._system_nodes.size() > 1)
	assert(world._systems.size() > 1)

func test_entitie_created() -> void:
	var world: World = worldruner.world
	var wrapper = {"emited": false, "entid": -1}
	world.events.on_entity_created.connect(func(e):
		wrapper["emited"] = true
		wrapper["entid"] = e
	)
	var id = world.create_entity()
	assert(wrapper["emited"])
	assert(wrapper["entid"] == id)
	assert(world.entities.living_count() == 1)

func test_entitie_deleted() -> void:
	var world: World = worldruner.world
	var entid = world.create_entity()
	var wrapper = {"emited": false, "deleted_id" :-1}
	world.events.on_entity_destroyed.connect(func(e):
		wrapper["emited"] = true
		wrapper["deleted_id"] = e
	)
	world.delete_entity(entid)
	assert(wrapper["emited"])
	assert(wrapper["deleted_id"] == entid)
	assert(world.entities.living_count() == 0)

func test_component_added() -> void:
	var world: World = worldruner.world
	var entid = world.create_entity()
	world.add_component(entid,DummyComponent.new())
	assert(world.has_component(entid,DummyComponent))

func test_component_removed() -> void:
	var world: World = worldruner.world
	var entid = world.create_entity()
	world.add_component(entid,DummyComponent.new())
	world.remove_component(entid,DummyComponent)
	assert(!world.has_component(entid,DummyComponent))

func test_try_to_remove_inexistent_component() -> void:
	var world: World = worldruner.world
	var entid = world.create_entity()
	assert_error(func(): world.remove_component(entid,DummyComponent))

func test_cant_add_same_comp_twice() -> void:
	var world: World = worldruner.world
	var entid = world.create_entity()
	world.add_component(entid,Component.new())
	assert_error(func(): world.add_component(entid,Component.new()))

func test_query_working() -> void:
	var world: World = worldruner.world
	var entid
	for i in range(10):
		entid = world.create_entity()
		world.add_component(entid,DummyComponent2.new())
	for i in range(5):
		entid = world.create_entity()
		world.add_component(entid,DummyComponent2.new())
		world.add_component(entid,DummyComponent.new())
	for i in range(10):
		entid = world.create_entity()
		world.add_component(entid,DummyComponent.new())
	var wrapper = {
		"entities_with_dc1": 0,
		"entities_with_dc2": 0,
		"entities_with_both": 0}
	world.query([DummyComponent]).for_each(func(_e,c):
		var ref: DummyComponent = c[0]
		assert(ref is DummyComponent)
		wrapper["entities_with_dc1"] +=1
		)
	assert(wrapper["entities_with_dc1"] ==15)
	world.query([DummyComponent2]).for_each(func(_e,c):
		var ref: DummyComponent2 = c[0]
		assert(ref is DummyComponent2)
		wrapper["entities_with_dc2"] +=1
		)
	assert(wrapper["entities_with_dc2"] == 15)
	world.query([DummyComponent,DummyComponent2]).for_each(func(_e,c):
		var ref: DummyComponent = c[0]
		var ref2: DummyComponent2 = c[1]
		assert(ref is DummyComponent)
		assert(ref2 is DummyComponent2)
		wrapper["entities_with_both"] +=1
	)
	assert(wrapper["entities_with_both"] == 5)

func test_get_component() -> void:
	var world: World = worldruner.world
	var entid = world.create_entity()
	var comp = DummyComponent.new()
	world.add_component(entid, comp)
	var retrieved = world.get_component(entid, DummyComponent)
	assert(retrieved == comp)

func test_get_component_no_storage() -> void:
	var world: World = worldruner.world
	var entid = world.create_entity()
	assert_error(func(): world.get_component(entid, DummyComponent))

func test_get_all_components() -> void:
	var world: World = worldruner.world
	var entid = world.create_entity()
	world.add_component(entid, DummyComponent.new())
	var all = world.get_all_components(entid)
	assert(all.size() == 1)
	assert(all[0]["entity"] == entid)
	assert(all[0]["type"] == "res://tests/dummy_component.gd")

func test_get_all_components_empty() -> void:
	var world: World = worldruner.world
	var entid = world.create_entity()
	var all = world.get_all_components(entid)
	assert(all.is_empty())

func test_storage_size() -> void:
	var world: World = worldruner.world
	var e1 = world.create_entity()
	var e2 = world.create_entity()
	world.add_component(e1, DummyComponent.new())
	world.add_component(e2, DummyComponent.new())
	assert(world.storage_size(DummyComponent) == 2)

func test_storage_size_no_storage() -> void:
	var world: World = worldruner.world
	assert(world.storage_size(DummyComponent) == 0)

func test_get_storage_null() -> void:
	var world: World = worldruner.world
	assert(world.get_storage(DummyComponent) == null)

func test_component_added_signal() -> void:
	var world: World = worldruner.world
	var entid = world.create_entity()
	var wrapper = {"emited": false}
	world.events.on_component_added.connect(func(e,c):
		assert(e == entid)
		assert(c == DummyComponent)
		wrapper["emited"] = true
	)
	world.add_component(entid, DummyComponent.new())
	assert(wrapper["emited"])

func test_component_removed_signal() -> void:
	var world: World = worldruner.world
	var entid = world.create_entity()
	world.add_component(entid, DummyComponent.new())
	var wrapper = {"emited": false}
	world.events.on_component_removed.connect(func(e,c):
		assert(e == entid)
		assert(c == DummyComponent)
		wrapper["emited"] = true
	)
	world.remove_component(entid, DummyComponent)
	assert(wrapper["emited"])

func test_get_system() -> void:
	var world: World = worldruner.world
	var sys = world.get_system(SystemNode)
	assert(sys != null)
	assert(sys is SystemNode)

func test_query_empty() -> void:
	var world: World = worldruner.world
	var called = false
	world.query([]).for_each(func(e,c): called = true)
	assert(!called)
