extends CardComponent
class_name ZoomableComponent

func ready(_card) -> void:
	_card.get_child(1).mouse_default_cursor_shape = Control.CURSOR_HELP

func on_drag_start(_card: Card) -> void:
	Globals.is_dragging = true
	_card.get_child(1).mouse_default_cursor_shape = Control.CURSOR_HELP
	var xf: Transform2D = _card.get_global_transform()
	var scale_x = xf.x.length() 
	var rodtation = xf.x.angle()
	_card.Scale(1.5/(scale_x/_card.scale.x))
	_card.Rotate(0.1,_card.rotation - rodtation)
	var disp_size: Vector2 = DisplayServer.window_get_size()/2
	var g_position: Vector2 = disp_size - _card.global_position 
	_card.Move(0.1,g_position) 

func on_drag_end(_card: Card) -> void:
	Globals.is_dragging = false
	_card.get_child(1).mouse_default_cursor_shape = Control.CURSOR_HELP
	_card.card_is_focused(false)
	_card.Move(0.1,_card.snap_pos,_card.snap_rot)
