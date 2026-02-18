class_name DiscardCardEventArgs
extends EventArgs

var card_entity: Entity
var discardzone: DropZone


func _init(_card_entity: Entity, _discardzone: DropZone):
	card_entity = _card_entity
	discardzone = _discardzone
