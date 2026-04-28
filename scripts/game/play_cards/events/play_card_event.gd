class_name PlayCardEvent
extends Event

var card_entity: Entity
var playzone: Entity


func _init(_card_entity: Entity, _playzone_entity: Entity) -> void:
	card_entity = _card_entity
	playzone = _playzone_entity
