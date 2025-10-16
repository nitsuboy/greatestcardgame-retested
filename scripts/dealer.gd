class_name Dealer
extends Node

const CARD_TYPE = preload("res://scripts/cards/Enums.gd").CardType

@export var question_deck: CardDeck
@export var answer_deck: CardDeck
@export var action_deck: CardDeck
@export var cardtemplate: PackedScene


func load_decks() -> void:
	question_deck.load_cards()
	answer_deck.load_cards()
	action_deck.load_cards()


func draw_card(card_type: CARD_TYPE) -> Card:
	var card_data: CardData
	var card: Card = cardtemplate.instantiate()
	match card_type:
		CARD_TYPE.ACTION:
			card_data = action_deck.draw()
		CARD_TYPE.ANSWER:
			card_data = answer_deck.draw()
		CARD_TYPE.QUESTION:
			card_data = question_deck.draw()
		_:
			return null
	if card_data:
		card.card_data = card_data
		return card
	push_warning("no more cards, deck %d" % card_type)
	return null
