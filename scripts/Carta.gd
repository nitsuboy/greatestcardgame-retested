extends Node
class_name Carta

@export var id:int
@export var carta_nome:String

@onready var carta_nome_label:Label = $front/card_control/margin/flex_container/name_label
@onready var carta_frente_background:Sprite2D = $front
@onready var carta_tras_background:Sprite2D = $back

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func Flip() -> void:
	carta_frente_background.visible = !carta_frente_background.visible
	carta_tras_background.visible = !carta_tras_background.visible

func FlipEspecifico(flipped:bool) -> void:
	carta_frente_background.visible = !flipped
	carta_tras_background.visible = flipped
