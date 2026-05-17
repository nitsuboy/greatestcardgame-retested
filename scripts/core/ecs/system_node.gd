@icon("res://scripts/core/icons/systemnode.svg")
@abstract class_name SystemNode
extends Node

var world: World
var replicator: Replicator


func init_system() -> void:
	pass


func update(_delta: float) -> void:
	pass


func cleanup() -> void:
	pass
