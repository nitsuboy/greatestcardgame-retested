class_name DrawOtherCardEvent
extends Event

var drawn_card: Entity
var player_id: int

func _init(_drawn_card: Entity, _player_id: int) -> void:
	drawn_card = _drawn_card
	player_id = _player_id
