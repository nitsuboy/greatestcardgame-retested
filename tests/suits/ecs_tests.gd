# GdUnit generated TestSuite
class_name ECSTests
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = "res://addons/truco/core/ecs/world.gd"

func test_world_creation() -> void:
	var runner = scene_runner("res://tests/worldrunnertest.tscn")
	var worldruner: WorldRunner = runner.invoke("find_child","WorldRunner")
	assert(worldruner.world)

func test_systems_added() -> void:
	var runner = scene_runner("res://tests/worldrunnertest.tscn")
	var worldruner: WorldRunner = runner.invoke("find_child","WorldRunner")
	var world: World = worldruner.world
	assert(worldruner._system_nodes.size() > 1)
	assert(world._systems.size() > 1)

func test_entitie_created() -> void:
	var runner = scene_runner("res://tests/worldrunnertest.tscn")
	var worldruner: WorldRunner = runner.invoke("find_child","WorldRunner")
	var world: World = worldruner.world
	var entid = world.create_entity()
	assert_signal(world.events).is_emitted("on_entity_created",[entid])
	assert(world.entities.living_count() == 1)

func test_entitie_deleted() -> void:
	var runner = scene_runner("res://tests/worldrunnertest.tscn")
	var worldruner: WorldRunner = runner.invoke("find_child","WorldRunner")
	var world: World = worldruner.world
	var entid = world.create_entity()
	assert_signal(world.events).is_emitted("on_entity_destroyed",[55555])
	world.delete_entity(entid)
	assert(world.entities.living_count() == 0)

func test_component_added() -> void:
	var runner = scene_runner("res://tests/worldrunnertest.tscn")
	var worldruner: WorldRunner = runner.invoke("find_child","WorldRunner")
	var world: World = worldruner.world
	var entid = world.create_entity()
	world.add_component(entid,DummyComponent.new())
	assert(world.has_component(entid,DummyComponent))

func test_component_removed() -> void:
	var runner = scene_runner("res://tests/worldrunnertest.tscn")
	var worldruner: WorldRunner = runner.invoke("find_child","WorldRunner")
	var world: World = worldruner.world
	var entid = world.create_entity()
	world.add_component(entid,DummyComponent.new())
	world.remove_component(entid,DummyComponent)
	assert(!world.has_component(entid,DummyComponent))

func test_try_to_remove_inexistent_component() -> void:
	var runner = scene_runner("res://tests/worldrunnertest.tscn")
	var worldruner: WorldRunner = runner.invoke("find_child","WorldRunner")
	var world: World = worldruner.world
	var entid = world.create_entity()
	assert_error(func(): world.remove_component(entid,DummyComponent))

func test_cant_add_same_comp_twice() -> void:
	var runner = scene_runner("res://tests/worldrunnertest.tscn")
	var worldruner: WorldRunner = runner.invoke("find_child","WorldRunner")
	var world: World = worldruner.world
	var entid = world.create_entity()
	world.add_component(entid,Component)
	assert_error(func(): world.add_component(entid,Component))

func test_query_working() -> void:
	var runner = scene_runner("res://tests/worldrunnertest.tscn")
	var worldruner: WorldRunner = runner.invoke("find_child","WorldRunner")
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
	world.query([DummyComponent]).for_each(func(e,c):
		var ref: DummyComponent = c[0]
		assert(ref is DummyComponent)
		wrapper["entities_with_dc1"] +=1
		)
	assert(wrapper["entities_with_dc1"] ==15)
	world.query([DummyComponent2]).for_each(func(e,c):
		var ref: DummyComponent2 = c[0]
		assert(ref is DummyComponent2)
		wrapper["entities_with_dc2"] +=1
		)
	assert(wrapper["entities_with_dc2"] == 15)
	world.query([DummyComponent,DummyComponent2]).for_each(func(e,c):
		var ref: DummyComponent = c[0]
		var ref2: DummyComponent2 = c[1]
		assert(ref is DummyComponent)
		assert(ref2 is DummyComponent2)
		wrapper["entities_with_both"] +=1
	)
	assert(wrapper["entities_with_both"] == 5)
