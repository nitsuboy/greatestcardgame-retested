class_name WorldRunner
extends Node

var world: World
var _system_nodes: Array[SystemNode]


func _init() -> void:
	world = World.new()


func _ready() -> void:
	for child in get_children():
		if child.has_method("_ecs_update"):
			_system_nodes.append(child)
			child.world = world


func _process(delta: float) -> void:
	world.events.on_frame_start.emit(delta)
	for sys in _system_nodes:
		sys._ecs_update(delta)
	world.events.on_frame_end.emit(delta)


func _exit_tree() -> void:
	world.clear()
