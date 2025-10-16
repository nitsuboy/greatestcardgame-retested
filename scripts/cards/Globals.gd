extends Node

var is_dragging: bool
var dg: Node


func _ready() -> void:
	Input.set_custom_mouse_cursor(load("res://assets/Hand1.png"), Input.CURSOR_POINTING_HAND)
	Input.set_custom_mouse_cursor(load("res://assets/Hand_Drag1.png"), Input.CURSOR_DRAG)
	Input.set_custom_mouse_cursor(load("res://assets/Arrow1.png"), Input.CURSOR_ARROW)
