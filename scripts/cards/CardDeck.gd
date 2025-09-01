extends Node
class_name CardDeck

signal DeckShuffled
signal CardDrawn(card_data: CardData)
signal DeckEmpty

const CardType = preload("res://scripts/cards/Enums.gd").CardType

@export var deck_type: CardType = CardType.QUESTION

var cards_data: Array[CardData] = []
var cards: Array[int] = []
var draw_pointer: int = 0
var discard_pointer: int = 0

func _ready() -> void:
	LoadCards(deck_type)
	Shuffle()

func LoadCardsFromPath(path: String) -> Array[CardData]:
	cards.clear()
	var dir = DirAccess.open(path)
	var loaded_cards : Array[CardData] = []
	var id: int = 0
	if dir:
		for file_name in dir.get_files():
			print(file_name)
			var card = load(path + "/" + file_name)
			if card is CardData:
				loaded_cards.append(card)
				for x in range(card.quantity):
					cards.append(id)
				id += 1
	return loaded_cards

func LoadCards(type:CardType) -> void:
	var path : String
	match type:
		CardType.QUESTION:
			path = "res://resources/cards/Questions"
		CardType.ANSWER:
			path = "res://resources/cards/Answers"
		CardType.ACTION:
			path = "res://resources/cards/Actions"
	var loaded_cards: Array[CardData] = LoadCardsFromPath(path)
	cards_data = loaded_cards.duplicate()
	draw_pointer = 0
	discard_pointer = cards.size() - 1

func Shuffle() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(draw_pointer,discard_pointer):
		var random_idx := rng.randi_range(i,discard_pointer)
		var temp := cards[i]
		cards[i] = cards[random_idx]
		cards[random_idx] = temp
	emit_signal("DeckShuffled")

func Draw() -> CardData:
	if draw_pointer > discard_pointer:
		emit_signal("DeckEmpty")
		return null
	var card: CardData = cards_data[cards[draw_pointer]]
	draw_pointer += 1
	emit_signal("CardDrawn", card)
	return card

func Discard(card: CardData) -> void:
	if draw_pointer == 0:
		return
	
	var ind: int = cards_data.find(card)
	
	if ind == -1:
		return
	
	var ind_aux: int = cards.find(ind)
	
	if ind_aux == -1:
		return
		
	for i in range(ind_aux,discard_pointer):
		cards[i] = cards[i+1]
	
	cards[discard_pointer] = ind
	draw_pointer -= 1
	discard_pointer -= 1

func InsertDiscard():
	discard_pointer = cards.size() - 1

func Reset() -> void:
	draw_pointer = 0 
	discard_pointer = cards.size() - 1
	Shuffle()
