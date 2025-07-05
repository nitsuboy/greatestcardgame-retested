extends Node
class_name CardDeck

signal DeckShuffled
signal CardDrawn(card_data: CardData)
signal DeckEmpty

enum DeckType { DESAFIO, JOGO, BONUS }

@export var deck_type: DeckType = DeckType.DESAFIO

var cards: Array[CardData] = []
var draw_pointer: int = 0
var discard_pointer: int = 0

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
	var path: String = GetJSONPath()
	var loaded_cards: Array[CardData] = CardLoader.LoadCardsFromFile(path)
	cards = loaded_cards.duplicate()
	draw_pointer = 0
	discard_pointer = cards.size() - 1

func Shuffle() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in cards.size():
		var rand_idx := rng.randi_range(i, cards.size() - 1)
		var temp := cards[i]
		cards[i] = cards[rand_idx]
		cards[rand_idx] = temp
	draw_pointer = 0
	discard_pointer = cards.size() - 1
	emit_signal("DeckShuffled")

func Draw() -> CardData:
	if draw_pointer > discard_pointer:
		emit_signal("DeckEmpty")
		return null
	var card: CardData = cards[draw_pointer]
	draw_pointer += 1
	emit_signal("CardDrawn", card)
	return card

func Discard(card: CardData) -> void:
	if discard_pointer < cards.size() - 1:
		discard_pointer += 1
		cards[discard_pointer] = card
	else:
		push_warning("Discard overflow: max deck size reached.")

func Reset() -> void:
	LoadCards()
	Shuffle()

func GetSize() -> int:
	return discard_pointer - draw_pointer + 1

func Has(card: CardData) -> bool:
	for i in range(draw_pointer, discard_pointer + 1):
		if cards[i] == card:
			return true
	return false

func Append(card: CardData) -> void:
	if discard_pointer < cards.size() - 1:
		discard_pointer += 1
		cards[discard_pointer] = card
	else:
		cards.append(card)
		discard_pointer = cards.size() - 1
