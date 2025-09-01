extends Resource
class_name CardData

const CardType = preload("res://scripts/cards/Enums.gd").CardType

@export var quantity: int = 1
@export var card_name: String = "Nova Carta"
@export var artwork : Texture2D
@export var description : String = ""
@export var card_type : CardType
