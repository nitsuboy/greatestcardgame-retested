extends Node

class_name PlayerHand

signal HandChanged

var cards: Array[CardData] = []

func AddCard(card: CardData) -> void:
	cards.append(card)
	emit_signal("HandChanged")
	
func RemoveCard(card: CardData) -> void:
	cards.erase(card)
	emit_signal("HandChanged")

func ClearHand() -> void:
	cards.clear()
	emit_signal("HandChanged")

func GetCardCount() -> void:
	return cards.size()

func GetCards() -> Array[CardData]:
	return cards.duplicate()
