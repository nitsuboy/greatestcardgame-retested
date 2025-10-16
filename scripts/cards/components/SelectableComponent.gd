class_name SelectableComponent
extends CardComponent


func ready(_card) -> void:
	_card.get_child(1).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
