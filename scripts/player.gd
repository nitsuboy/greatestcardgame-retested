class_name Player
extends Node2D

@export var hand: PlayerHand

var id: String
var points: int = 0
var tests_max: int = 0
var tests_left: int = 0


func _process(_delta: float) -> void:
	$RichTextLabel.text = "%d , %d" % [tests_left, tests_max]


# --- Propriedas ---


func reset_tests() -> void:
	tests_left = tests_max


func add_tests(quantity: int) -> void:
	tests_max += quantity
	tests_left += quantity


# --- Cartas ---


func add_card_to_hand(card: Card) -> void:
	card.holder = self
	hand.add_card(card)



func remove_card_from_hand(card: CardData) -> void:
	hand.erase(card)
