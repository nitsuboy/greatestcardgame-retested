## Base class for all ECS systems.
##
## Lifecycle managed by WorldRunner:
## 1. WorldRunner._ready injects world and replicator
## 2. WorldRunner calls init_system() (after all systems are registered)
## 3. Every frame, WorldRunner._process calls update(delta)
## 4. On removal, cleanup() is called
##
## Systems can connect to world signals (events, replicator)
## inside init_system().
class_name SystemNode
extends Node

var world: World
var replicator: Replicator


## Called once after world and replicator are injected.
## Use to connect signals and initialize dependencies.
func init_system() -> void:
	pass


## Called every frame by WorldRunner.
## Use for continuous logic (queries, animations, etc).
func update(_delta: float) -> void:
	pass


## Called when the system is removed from the tree.
## Use to clean up resources and disconnect signals.
func cleanup() -> void:
	pass
