class_name PlayCardEventArgs
extends EventArgs

var card_entity: Entity
var playzone: DropZone

func _init(_card_entity: Entity, _playzone: DropZone):
	card_entity = _card_entity
	playzone = _playzone
