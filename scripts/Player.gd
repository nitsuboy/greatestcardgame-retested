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
var test_limit: int = 0
var tests_used: int = 0

func AddCardToHand(card: CardData) -> void:
	hand.AddCard(card)
	emit_signal("HandUpdated")

func RemoveCardFromHand(card: CardData) -> void:
	hand.RemoveCard(card)
	emit_signal("HandUpdated")

func AddPoint() -> void:
	score += 1
	emit_signal("ScoreUpdated")

func ReceiveCard(card: CardData) -> void:
	AddCardToHand(card)

func HasTestador() -> bool:
	for card in hand.GetCards():
		if card.description.contains("Testador"):
			return true
	return false

func HasEstagiario() -> bool:
	for card in hand.GetCards():
		if card.description.contains("Estagiário"):
			return true
	return false

func CanAttemptTest() -> bool:
	return tests_used < test_limit

func ConsumeTest() -> void:
	tests_used += 1

func SetTestLimit(limit: int) -> void:
	test_limit = limit
	tests_used = 0
