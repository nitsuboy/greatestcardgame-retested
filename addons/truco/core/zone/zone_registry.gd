## Maps zone_id → Node for fast zone lookup.
##
## Registered as a global autoload (Zones). Used by
## CardSpawnerSystem and DropSystem to locate zones.
class_name ZoneRegistry
extends Node

var _zones: Dictionary[int, Node] = {}


## Registers a node with a zone_id.
func register(id: int, node: Node) -> void:
	_zones[id] = node


## Returns the node of a zone by its ID.
func get_zone(id: int) -> Node:
	return _zones.get(id)


## Removes a zone registration.
func unregister(id: int) -> void:
	_zones.erase(id)
