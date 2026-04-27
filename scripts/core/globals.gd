extends Node

var is_dragging: bool
var game = preload("res://scenes/simple_game.tscn")
var lobby = preload("res://scenes/lobby.tscn")
var debug: bool = false


func _ready() -> void:
	Input.set_custom_mouse_cursor(load("res://assets/hand.png"), Input.CURSOR_POINTING_HAND)
	Input.set_custom_mouse_cursor(load("res://assets/hand_drag.png"), Input.CURSOR_DRAG)
	Input.set_custom_mouse_cursor(load("res://assets/arrow.png"), Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(load("res://assets/zoom.png"), Input.CURSOR_HELP)
