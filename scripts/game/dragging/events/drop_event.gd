class_name DropEvent
extends Event

var card_entity: Entity
var drop_zone: DropZone


func _init(card: Entity, _drop_zone: DropZone) -> void:
	card_entity = card
	drop_zone = _drop_zone
