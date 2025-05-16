extends Node

class_name Player

signal HandUpdated
signal ScoreUpdated

@export var player_id: int = -1
@export var player_name: String = ""
@export var is_local: bool = false
@export var is_host: bool = false

@onready var hand: PlayerHand = $Hand

var score: int = 0

func AddCardToHand(card: CardData) -> void:
	hand.AddCard(card)
	emit_signal("HandUpdated")

func RemoveCardFromHand(card: CardData) -> void:
	hand.RemoveCard(card)
	emit_signal("HandUpdated")

func AddPoint() -> void:
	score += 1
	emit_signal("ScoreUpdated")

func Reset() -> void:
	score = 0
	hand.ClearHand()
