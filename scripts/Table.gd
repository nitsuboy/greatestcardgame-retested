extends Control

class_name Table

signal CardReplaced(index: int, new_card: CardData)

#temporario
@export var container : HBoxContainer
@export var cardtemplate : PackedScene

var cards: Array[Card] = []

const MAX_CARDS: int = 5

func Setup(initial_cards: Array[CardData]) -> void:
	cards.clear()
	for i in range(min(initial_cards.size(), MAX_CARDS)):
		cards.append(initial_cards[i])

func GetCards() -> Array[Card]:
	return cards.duplicate()

func AddDesafioCard(card: Card) -> void:
	if cards.size() >= MAX_CARDS:
		push_warning("Maximum number of Desafio cards reached.")
		return
	cards.append(card)
	container.add_child(card)

func RemoveDesafioCard(card: CardData) -> void:
	var index := cards.find(card)
	if index == -1:
		push_warning("Desafio card not found on table.")
		return
	cards.remove_at(index)
