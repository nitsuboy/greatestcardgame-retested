class_name Player
extends Node2D

@export var hand: PlayerHand
@export var debug: RichTextLabel

var id: String
var is_ai: bool = false

# --- Cartas ---


func add_card(card: Card) -> void:
	card.holder = self
	hand.add_card(card)


func remove_card_from_hand(card: CardData) -> void:
	hand.erase(card)
