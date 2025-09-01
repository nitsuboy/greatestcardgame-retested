extends Node

class_name Dealer

const CardType = preload("res://scripts/cards/Enums.gd").CardType

var question_deck: CardDeck
var answer_deck: CardDeck
var action_deck: CardDeck

func LoadDecks() -> void:
	question_deck = CardDeck.new()
	question_deck.LoadCards(CardType.QUESTION)

	answer_deck = CardDeck.new()
	answer_deck.LoadCards(CardType.ANSWER)

	action_deck = CardDeck.new()
	action_deck.LoadCards(CardType.ACTION)

func DealInitialHand(player: Player, count: int = 5) -> void:
	for i in range(count):
		var card := answer_deck.Draw()
		if card:
			player.add_card_to_hand(card)

func DrawCard(cardtype : CardType) -> CardData:
	match cardtype:
		CardType.ACTION:
			return action_deck.Draw()
		CardType.ANSWER:
			return answer_deck.Draw()
		CardType.QUESTION:
			return question_deck.Draw()
		_:
			return null

func AddDesafioCard(card: CardData) -> void:
	if not question_deck.has(card):
		question_deck.append(card)

func RemoveDesafioCard(card: CardData) -> void:
	if question_deck.has(card):
		question_deck.erase(card)
