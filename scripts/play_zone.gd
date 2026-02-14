class_name ActionZone
extends Control

signal action(card,zone)

@export var static_container: VStaticContainer

func _ready() -> void:
	get_child(0).entity.id = 0
	get_child(0).entity.all_entities[0] = get_child(0).entity

func add_card(node: Node) -> void:
	static_container.add_child(node)
