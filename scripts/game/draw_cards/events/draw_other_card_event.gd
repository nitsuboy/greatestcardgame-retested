class_name DrawOtherCardEvent
extends Event

var drawn_card: Entity


func _init(_drawn_card: Entity) -> void:
	drawn_card = _drawn_card
