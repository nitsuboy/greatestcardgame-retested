extends Node2D

var world = World.new()


func _ready() -> void:
	# add components (Resources)
	for i in range(50):
		var ent = world.create_entity()
		world.add_component(ent, PlayerComponent.new())
		world.add_component(ent, PlayableComponent.new())

	# query
	world.query([PlayerComponent]).for_each(
		func(entity, comps):
			var player_comp: PlayerComponent = comps[0]
			print("player entity: ", entity)
	)

	world.query([PlayableComponent, PlayerComponent]).for_each(
		func(entity, comps):
			var playble_comp: PlayableComponent = comps[0]
			var player_comp: PlayerComponent = comps[1]
			print("card entity: ", entity)
	)

	world.events.on_component_added.connect(func(e, t): print("component added to ", e))


func _process(delta: float) -> void:
	# game loop
	world.update(delta)
	# events
