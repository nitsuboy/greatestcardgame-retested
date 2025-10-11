extends Node2D
class_name Player

signal TurnEnded

@export var hand: PlayerHand
 
var id: String
var is_human: bool = true
var points: int = 0
var test_limit: int = 1
var tests_taken: int = 0

# --- Turno ---
func start_turn() -> void:
	pass

func end_turn() -> void:
	emit_signal("TurnEnded")

func can_attempt_test() -> bool:
	return tests_taken < test_limit

func consume_test() -> void:
	tests_taken += 1

func add_point() -> void:
	points += 1

func set_test_limit(limit: int) -> void:
	test_limit = limit

# --- Cartas ---
func add_card_to_hand(card: Card) -> void:
	card.holder = self
	hand.AddCard(card)
	

func remove_card_from_hand(card: CardData) -> void:
	hand.erase(card)
