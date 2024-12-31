extends Carta
class_name CartaPergunta

@export var carta_perg_str:String = "lorem ipsun"

@onready var carta_perg:RichTextLabel = $front/card_control/margin/flex_container/centering_container/desc_label

func _ready() -> void:
	carta_perg.text = carta_perg_str

func _process(delta: float) -> void:
	pass
