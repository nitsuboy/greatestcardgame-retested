class_name DraggableComponent
extends CardComponent


func ready(_card) -> void:
	_card.get_child(1).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func on_drag_start(_card: Card) -> void:
	_card.get_child(1).mouse_default_cursor_shape = Control.CURSOR_DRAG
	var xf: Transform2D = _card.get_global_transform()
	var scale_x = xf.x.length()
	var rodtation = xf.x.angle()
	_card.resize(1.2 / (scale_x / _card.scale.x))
	_card.rotate(0.1, _card.rotation - rodtation)
	_card.dragging = true


func on_drag_end(_card: Card) -> void:
	_card.get_child(1).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_card.dragging = false
	Globals.is_dragging = false
	_card.card_is_focused(false)
	_card.move(0.1, _card.snap_pos, _card.snap_rot)
