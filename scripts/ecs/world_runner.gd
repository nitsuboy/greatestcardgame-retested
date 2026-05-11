class_name WorldRunner
extends Node

@export var replicator: Replicator
var world: World
var _system_nodes: Array[SystemNode]


func _ready() -> void:
	world = World.new()
	for child in get_children():
		child.world = world
		if child is SystemNode:
			child.init_system()
			child.replicator = replicator
			world.register_system(child, child.get_script())
			_system_nodes.append(child)


func _process(delta: float) -> void:
	world.events.on_frame_start.emit(delta)
	for sys in _system_nodes:
		sys.update(delta)
	world.events.on_frame_end.emit(delta)
