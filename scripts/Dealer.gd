extends Node

class_name Dealer

const CardType = preload("res://scripts/cards/Enums.gd").CardType

@export var question_deck: CardDeck
@export var answer_deck: CardDeck
@export var action_deck: CardDeck
@export var cardtemplate : PackedScene

func LoadDecks() -> void:
	question_deck.LoadCards()
	answer_deck.LoadCards()
	action_deck.LoadCards()

func DrawCard(cardtype : CardType) -> Card:
	var card_data : CardData
	var card : Card = cardtemplate.instantiate()
	match cardtype:
		CardType.ACTION:
			card_data = action_deck.Draw()
		CardType.ANSWER:
			card_data = answer_deck.Draw()
		CardType.QUESTION:
			card_data = question_deck.Draw()
		_:
			return null
	if card_data:
		card.card_data = card_data
		return card
	push_warning("no more cards, deck %d" % cardtype)
	return null
