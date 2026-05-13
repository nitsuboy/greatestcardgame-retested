extends Node2D

var world = World.new()


func _teste(ent):
	print("cosk")


func _ready() -> void:
	# add components (Resources)

	world.events.on_entity_created.connect(_teste)
	world.events.on_component_added.connect(func(e, t): print("component added to ", e))

	for i in range(50):
		var ent = world.create_entity()
