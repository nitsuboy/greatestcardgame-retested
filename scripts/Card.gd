extends Node
class_name Card

@export var card_name:String

@onready var card_name_label:Label = $front/card_control/margin/flex_container/name_label
@onready var card_front_background:Sprite2D = $front
@onready var card_back_background:Sprite2D = $back

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
