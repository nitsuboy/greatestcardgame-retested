extends Resource
class_name CardData

const CardType = preload("res://scripts/cards/Enums.gd").CardType

@export var card_name: String = "Nova Carta"
@export var artwork: Texture2D
@export var description: String = ""
@export var effects: Array[Effect]
@export var components: Array[CardComponent]
