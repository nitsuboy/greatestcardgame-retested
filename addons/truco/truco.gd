@tool
extends EditorPlugin


func _enable_plugin() -> void:
	add_autoload_singleton("Conn", "res://addons/truco/core/network/ecs_connection.gd")
	add_autoload_singleton("Players", "res://addons/truco/core/player/player_registry.gd")
	add_autoload_singleton("Sync", "res://addons/truco/core/network/sync_barrier.gd")
	add_autoload_singleton("Remote", "res://addons/truco/core/network/remote_action.gd")
	add_autoload_singleton("Zones", "res://addons/truco/core/zone/zone_registry.gd")


func _disable_plugin() -> void:
	remove_autoload_singleton("Conn")
	remove_autoload_singleton("Players")
	remove_autoload_singleton("Sync")
	remove_autoload_singleton("Remote")
	remove_autoload_singleton("Zones")


func _enter_tree() -> void:
	add_custom_type(
		"WorldRunner",
		"Node",
		preload("res://addons/truco/core/ecs/world_runner.gd"),
		preload("res://addons/truco/icons/world.svg")
	)
	add_custom_type(
		"SystemNode",
		"Node",
		preload("res://addons/truco/core/ecs/system_node.gd"),
		preload("res://addons/truco/icons/systemnode.svg")
	)
	add_custom_type(
		"DropZone",
		"Node2D",
		preload("res://addons/truco/core/zone/drop_zone.gd"),
		preload("res://addons/truco/icons/zone.svg")
	)


func _exit_tree() -> void:
	remove_custom_type("WorldRunner")
	remove_custom_type("SystemNode")
	remove_custom_type("DropZone")
