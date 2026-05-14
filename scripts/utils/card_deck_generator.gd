extends Node


func _ready() -> void:
	var deck := CardDeck.new()

	for value in range(10):
		for color in range(4):
			var qty = 1 if value == 0 else 2
			deck.cards_quantity.append(qty)
			var card := CardData.new()
			card.card_name = str(value)
			card.card_value = value
			card.card_color = color
			_add_base_components(card, color, value)
			deck.cards_data.append(card)

	# SKIP
	for color in range(4):
		deck.cards_quantity.append(2)
		var card := CardData.new()
		card.card_name = "SKP"
		card.card_value = Card.CardValue.SKIP
		card.card_color = color
		_add_base_components(card, color, Card.CardValue.SKIP)
		_add_effect(card, Effect.Type.SKIP, 1)
		deck.cards_data.append(card)

	# REVERSE
	for color in range(4):
		deck.cards_quantity.append(2)
		var card := CardData.new()
		card.card_name = "REV"
		card.card_value = Card.CardValue.REVERSE
		card.card_color = color
		_add_base_components(card, color, Card.CardValue.REVERSE)
		_add_effect(card, Effect.Type.REVERSE, 1)
		deck.cards_data.append(card)

	# +2
	for color in range(4):
		deck.cards_quantity.append(2)
		var card := CardData.new()
		card.card_name = "+2"
		card.card_value = Card.CardValue.PLUSTWO
		card.card_color = color
		_add_base_components(card, color, Card.CardValue.PLUSTWO)
		_add_effect(card, Effect.Type.DRAW, 2)
		deck.cards_data.append(card)

	# +4
	deck.cards_quantity.append(4)
	var wild4 := CardData.new()
	wild4.card_name = "+4"
	wild4.card_value = Card.CardValue.PLUSFOUR
	wild4.card_color = Card.CardColor.WILD
	_add_base_components(wild4, Card.CardColor.WILD, Card.CardValue.PLUSFOUR)

	var effects4 := CardEffectsComponent.new()
	var draw4 := Effect.new()
	draw4.type = Effect.Type.DRAW
	draw4.amount = 4
	effects4.on_play.append(draw4)
	var wild := Effect.new()
	wild.type = Effect.Type.WILD
	effects4.on_play.append(wild)
	wild4.components.append(effects4)
	deck.cards_data.append(wild4)

	ResourceSaver.save(deck, "res://resources/deck_test.tres")
	print("Deck salvo em res://resources/deck_test.tres")
	get_tree().quit()


func _add_base_components(card: CardData, color: int, value: int) -> void:
	var card_comp := CardComponent.new()
	card_comp.color = color
	card_comp.value = value
	card.components.append(card_comp)
	card.components.append(DraggableComponent.new())
	card.components.append(HoverableComponent.new())


func _add_effect(card: CardData, type: Effect.Type, amount: int = 1) -> void:
	var effects := CardEffectsComponent.new()
	var effect := Effect.new()
	effect.type = type
	effect.amount = amount
	effects.on_play.append(effect)
	card.components.append(effects)
