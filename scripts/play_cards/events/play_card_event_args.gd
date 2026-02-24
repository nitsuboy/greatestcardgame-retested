class_name PlayCardEventArgs
extends EventArgs

var card_entity: Entity
var playzone: Entity


func _init(_card_entity: Entity, _playzone_entity: Entity):
	card_entity = _card_entity
	playzone = _playzone_entity
