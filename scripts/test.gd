extends Node2D


func _ready() -> void:
	$Card.post_instantiate($WorldRunner.world)
	$WorldRunner.world.add_component(0, HoverableComponent.new())
	$WorldRunner.world.add_component(0, DraggableComponent.new())
	$ActionZone.post_instantiate($WorldRunner.world)
