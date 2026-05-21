## Deck of cards with support for shuffle, draw, discard and peek.
##
## Serializable resource that defines a complete deck:
## - cards_data: available card types
## - cards_quantity: quantity of each type
## Manages draw and discard pointers internally.
class_name CardDeck
extends Resource

## List of card types in the deck.
@export var cards_data: Array[CardData]
## Quantity of each card type (same index as cards_data).
@export var cards_quantity: Array[int]

## Internal card indices (current order after shuffle).
var cards: Array[int] = []
## Pointer to the top of the deck (next card to draw).
var draw_pointer: int = 0
## Pointer to the end of the deck (last available card).
var discard_pointer: int = 0


## Loads and builds the internal card array based on quantities.
func load_cards() -> void:
	cards.clear()
	var id: int = 0
	for c in cards_data:
		for x in range(cards_quantity[id]):
			cards.append(id)
		id += 1
	draw_pointer = 0
	discard_pointer = cards.size() - 1


## Shuffles the cards between draw_pointer and discard_pointer.
func shuffle() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(draw_pointer, discard_pointer):
		var random_idx := rng.randi_range(i, discard_pointer)
		var temp := cards[i]
		cards[i] = cards[random_idx]
		cards[random_idx] = temp


## Draws a card from the top of the deck. If id != -1, draws specific type.
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


## Peeks at a card without drawing (amount positions ahead).
func peek(amount: int = 0) -> CardData:
	if (draw_pointer + amount) > discard_pointer:
		return null
	return cards_data[cards[draw_pointer + amount]]


## Discards a specific card (moves to end of array).
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


## Reinserts discard (allows recycling discarded cards).
func insert_discard() -> void:
	discard_pointer = cards.size() - 1


## Resets the deck: draw_pointer = 0, reshuffles.
func reset() -> void:
	draw_pointer = 0
	discard_pointer = cards.size() - 1
	shuffle()
