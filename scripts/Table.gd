extends Control

class_name Table

signal CardReplaced(index: int, new_card: CardData)

#temporario
@export var container : HBoxContainer
@export var cardtemplate : PackedScene

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

func AddDesafioCard(card: CardData) -> void:
	if cards.size() >= MAX_CARDS:
		push_warning("Maximum number of Desafio cards reached.")
		return
	cards.append(card)
	var newc = cardtemplate.instantiate()
	newc.card_data = card
	container.add_child(newc)

func RemoveDesafioCard(card: CardData) -> void:
	var index := cards.find(card)
	if index == -1:
		push_warning("Desafio card not found on table.")
		return
	cards.remove_at(index)
