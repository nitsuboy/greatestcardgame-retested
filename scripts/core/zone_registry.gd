class_name ZoneRegistry
extends Node

var _zones: Dictionary[int, Node] = {}


func register(id: int, node: Node) -> void:
	_zones[id] = node


func get_zone(id: int) -> Node:
	return _zones.get(id)


func unregister(id: int) -> void:
	_zones.erase(id)
