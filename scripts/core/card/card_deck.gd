class_name CardDeck
extends Resource

@export var cards_data: Array[CardData]
@export var cards_quantity: Array[int]

var cards: Array[int] = []
var draw_pointer: int = 0
var discard_pointer: int = 0


func load_cards() -> void:
	cards.clear()
	var id: int = 0
	for c in cards_data:
		c.id = id
		for x in range(cards_quantity[id]):
			cards.append(id)
		id += 1
	draw_pointer = 0
	discard_pointer = cards.size() - 1


func shuffle() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(draw_pointer, discard_pointer):
		var random_idx := rng.randi_range(i, discard_pointer)
		var temp := cards[i]
		cards[i] = cards[random_idx]
		cards[random_idx] = temp


func draw(id: int = -1) -> CardData:
	var card: CardData
	if id == -1:
		if draw_pointer > discard_pointer:
			return null
		card = cards_data[cards[draw_pointer]]
		draw_pointer += 1
	else:
		card = cards_data[id]
	return card


func peek(amount: int = 0) -> CardData:
	var card: CardData
	if (draw_pointer + amount) > discard_pointer:
		return null
	card = cards_data[cards[draw_pointer + amount]]


func discard(card: CardData) -> void:
	if draw_pointer == 0:
		return

	var ind: int = cards_data.find(card)

	if ind == -1:
		return

	var ind_aux: int = cards.find(ind)

	if ind_aux == -1:
		return

	for i in range(ind_aux, discard_pointer):
		cards[i] = cards[i + 1]

	cards[discard_pointer] = ind
	draw_pointer -= 1
	discard_pointer -= 1


func insert_discard() -> void:
	discard_pointer = cards.size() - 1


func reset() -> void:
	draw_pointer = 0
	discard_pointer = cards.size() - 1
	shuffle()
