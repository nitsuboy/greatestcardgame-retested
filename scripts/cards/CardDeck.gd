extends Resource
class_name CardDeck

signal DeckShuffled
signal CardDrawn(card_data: CardData)

@export var cards_data: Array[CardData]
@export var cards_quantity: Array[int]

const CardType = preload("res://scripts/cards/Enums.gd").CardType

var cards: Array[int] = []
var draw_pointer: int = 0
var discard_pointer: int = 0

func _ready() -> void:
	LoadCards()
	Shuffle()

func LoadCards() -> void:
	cards.clear()
	var id: int = 0
	for c in cards_data:
		for x in range(cards_quantity[id]):
			cards.append(id)
		id += 1
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
