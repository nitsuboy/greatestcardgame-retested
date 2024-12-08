extends Card
class_name CardNormal

@export var card_icon_id:String = "100"
@export var card_desc_str:String = "lorem ipsun"
@export var card_type:String = "lorem ipsun"

@onready var card_icon:TextureRect = $front/card_control/margin/flex_container/CenterContainer/icon_rect
@onready var card_desc:RichTextLabel = $front/card_control/margin/flex_container/centering_container/desc_label

func _ready() -> void:
	card_desc.text = card_desc_str
	card_icon.texture = load("res://tex/icon/"+card_icon_id+".png")
	card_back_background.texture = load("res://tex/card/"+card_type+"b.png")
	card_front_background.texture = load("res://tex/card/"+card_type+"f.png")

func _process(delta: float) -> void:
	pass
