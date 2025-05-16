extends Node
class_name CardDeck

signal DeckShuffled
signal CardDrawn(card_data : CardData)
signal DeckEmpty

enum DeckType { DESAFIO, JOGO, BONUS }

@export var deck_type : DeckType = DeckType.DESAFIO

var cards : Array[CardData] = []
var discard_pile : Array[CardData] = []

func _ready() -> void:
	LoadCards()
	Shuffle()

func GetJSONPath() -> String:
	match deck_type:
		DeckType.DESAFIO:
			return "res://resources/cards/desafio_cards.json"
		DeckType.JOGO:
			return "res://resources/cards/jogo_cards.json"
		DeckType.BONUS:
			return "res://resources/cards/bonus_cards.json"
		_:
			return ""

func LoadCards() -> void:
	cards.clear()
	discard_pile.clear()
	
	var path := GetJSONPath()
	if path == "":
		push_error("invalid deck type or path.")
		return
	
	var loaded_cards : Array[CardData] = CardLoader.LoadCardsFromFile(path)
	for card in loaded_cards:
		cards.append(card)

func Shuffle() -> void:
	cards.shuffle()
	discard_pile.clear()
	emit_signal("DeckShuffled")

func Draw() -> CardData:
	if cards.is_empty():
		if discard_pile.is_empty():
			emit_signal("DeckEmpty")
			return null
		else:
			cards = discard_pile.duplicate()
			cards.shuffle()
			discard_pile.clear()
			emit_signal("DeckShuffled")
	
	var drawn_card : CardData = cards.pop_front()
	emit_signal("CardDrawn", drawn_card)
	return drawn_card

func Discard(card : CardData) -> void:
	discard_pile.append(card)

func GetSize() -> void:
	return cards.size();

func Reset() -> void:
	LoadCards()
	Shuffle()
