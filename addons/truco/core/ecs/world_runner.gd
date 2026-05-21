## ECS entry point. Must be the parent of all systems in the scene tree.
##
## _ready() flow:
## 1. Creates the World
## 2. Injects world and replicator into all SystemNode children
## 3. Registers each system in the World (world.register_system)
## 4. Calls init_system() on each system
##
## Injection uses two loops so that during init_system() all systems
## are already registered and can reference each other via world.get_system().
class_name WorldRunner
extends Node

@export var replicator: Replicator
var world: World
var _system_nodes: Array[SystemNode]


func _ready() -> void:
	world = World.new()

	# Loop 1: inject dependencies and register systems
	for child in get_children():
		child.world = world
		child.replicator = replicator
		world.register_system(child, child.get_script())
		_system_nodes.append(child)

	# Loop 2: initialize (all systems already registered)
	for child in get_children():
		child.init_system()


func _process(delta: float) -> void:
	for sys in _system_nodes:
		sys.update(delta)
