class_name WorldRunner
extends Node

var world: World
var _system_nodes: Array[SystemNode]


func _ready() -> void:
	world = World.new()
	for child: SystemNode in get_children():
		child.world = world
		child.init_system()
		if child.has_method("_ecs_update"):
			_system_nodes.append(child)


func _process(delta: float) -> void:
	world.events.on_frame_start.emit(delta)
	for sys in _system_nodes:
		sys._ecs_update(delta)
	world.events.on_frame_end.emit(delta)
