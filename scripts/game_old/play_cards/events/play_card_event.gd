class_name PlayCardEvent
extends Event

var playzone: Entity


func _init(_playzone_entity: Entity) -> void:
	playzone = _playzone_entity
