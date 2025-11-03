extends Node

var is_dragging: bool
var dg: Node


func _ready() -> void:
	Input.set_custom_mouse_cursor(load("res://assets/hand1.png"), Input.CURSOR_POINTING_HAND)
	Input.set_custom_mouse_cursor(load("res://assets/hand__drag1.png"), Input.CURSOR_DRAG)
	Input.set_custom_mouse_cursor(load("res://assets/arrow1.png"), Input.CURSOR_ARROW)
