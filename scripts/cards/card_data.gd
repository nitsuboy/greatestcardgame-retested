class_name CardData
extends Resource

const CARD_TYPE = preload("res://scripts/cards/Enums.gd").CardType

@export var card_name: String = "Nova Carta"
@export var artwork: Texture2D
@export var description: String = ""
@export var components: Array[Component]
