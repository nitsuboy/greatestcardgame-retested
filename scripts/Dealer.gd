extends Node

class_name Dealer

@export var desafio_cards_path: String = "res://resources/cards/desafio_cards.json"
@export var game_cards_path: String = "res://resources/cards/jogo_cards.json"
@export var bonus_cards_path: String = "res://resources/cards/bonus_cards.json"

var desafio_deck: CardDeck
var game_deck: CardDeck
var bonus_deck: CardDeck

func _ready() -> void:
	_LoadDecks()

func _LoadDecks() -> void:
	desafio_deck = CardDeck.new()
	desafio_deck.LoadFromJson(desafio_cards_path, "Desafio")

	game_deck = CardDeck.new()
	game_deck.LoadFromJson(game_cards_path, "Game")

	bonus_deck = CardDeck.new()
	bonus_deck.LoadFromJson(bonus_cards_path, "Bonus")

func DealInitialHand(player: Player, count: int = 5) -> void:
	for i in range(count):
		var card := game_deck.Draw()
		if card:
			player.AddCardToHand(card)

func DrawGameCard() -> CardData:
	return game_deck.Draw()

func DrawBonusCard() -> CardData:
	return bonus_deck.Draw()

func DrawDesafioCard() -> CardData:
	return desafio_deck.Draw()

func AddDesafioCard(card: CardData) -> void:
	if not desafio_deck.has(card):
		desafio_deck.append(card)

func RemoveDesafioCard(card: CardData) -> void:
	if desafio_deck.has(card):
		desafio_deck.erase(card)
