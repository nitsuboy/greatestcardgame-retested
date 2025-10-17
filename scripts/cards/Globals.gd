extends Node

var is_dragging : bool
var dg:Node

func _ready() -> void:
	Input.set_custom_mouse_cursor(load("res://tex/Hand1.png"),Input.CURSOR_POINTING_HAND)
	Input.set_custom_mouse_cursor(load("res://tex/Hand_Drag1.png"),Input.CURSOR_DRAG)
	Input.set_custom_mouse_cursor(load("res://tex/Arrow1.png"),Input.CURSOR_ARROW)
