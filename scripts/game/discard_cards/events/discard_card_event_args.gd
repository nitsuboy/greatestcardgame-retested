class_name DiscardCardEventArgs
extends EventArgs

var card_entity: Entity


func _init(_card_entity: Entity) -> void:
	card_entity = _card_entity
