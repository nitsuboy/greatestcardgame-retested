extends Carta
class_name CartaNormal

@export var carta_icon_id:String = "100"
@export var carta_desc_str:String = "lorem ipsun"
@export var carta_tipo:String = "lorem ipsun"

@onready var carta_icon:TextureRect = $front/card_control/margin/flex_container/CenterContainer/icon_rect
@onready var carta_desc:RichTextLabel = $front/card_control/margin/flex_container/centering_container/desc_label

func _ready() -> void:
	carta_desc.text = carta_desc_str
	carta_icon.texture = load("res://tex/icon/"+carta_icon_id+".png")
	carta_tras_background.texture = load("res://tex/card/"+carta_tipo+"b.png")
	carta_frente_background.texture = load("res://tex/card/"+carta_tipo+"f.png")

func _process(delta: float) -> void:
	pass
