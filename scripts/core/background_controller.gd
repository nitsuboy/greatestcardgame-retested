class_name BackgroundController
extends Node

@export var color_rect_path: NodePath

var _color_rect: ColorRect


func _ready() -> void:
	if color_rect_path:
		_color_rect = get_node(color_rect_path) as ColorRect


func set_card_color(color: int) -> void:
	if not _color_rect:
		return
	match color:
		Card.CardColor.YELLOW:
			_color_rect.set_color_shader(Color.YELLOW)
		Card.CardColor.BLUE:
			_color_rect.set_color_shader(Color.BLUE)
		Card.CardColor.RED:
			_color_rect.set_color_shader(Color.RED)
		Card.CardColor.GREEN:
			_color_rect.set_color_shader(Color.GREEN)
		Card.CardColor.WILD:
			_color_rect.set_color_shader(Color.ANTIQUE_WHITE)


func set_direction(forward: bool) -> void:
	if not _color_rect:
		return
	_color_rect.change_direction(forward)


func reset() -> void:
	if not _color_rect:
		return
	_color_rect.set_color_shader(Color.ANTIQUE_WHITE)
	_color_rect.change_direction(true)
