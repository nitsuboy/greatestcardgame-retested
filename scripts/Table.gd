extends Node2D

class_name Table

signal CardReplaced(index: int, new_card: CardData)

var cards: Array[CardData] = []

const MAX_CARDS: int = 5

func Setup(initial_cards: Array[CardData]) -> void:
	cards.clear()
	for i in range(min(initial_cards.size(), MAX_CARDS)):
		cards.append(initial_cards[i])

func ReplaceCard(index: int, new_card: CardData) -> void:
	if index < 0 or index >= cards.size():
		push_error("Invalid Desafio card index: %d" % index)
		return
	
	cards[index] = new_card
	emit_signal("CardReplaced", index, new_card)

func GetCards() -> Array[CardData]:
	return cards.duplicate()
