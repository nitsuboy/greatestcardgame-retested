extends Node


func _ready() -> void:
	var deck := CardDeck.new()

	# Cartas normais 0-9 (2 de cada, 4 cores)
	for value in range(10):
		for color in range(4):
			var qty = 1 if value == 0 else 2
			deck.cards_quantity.append(qty)
			var card := CardData.new()
			card.card_name = str(value)
			card.card_value = value
			card.card_color = color
			deck.cards_data.append(card)

	# SKIP (10)
	for color in range(4):
		deck.cards_quantity.append(2)
		var card := CardData.new()
		card.card_name = "SKP"
		card.card_value = Card.CardValue.SKIP
		card.card_color = color
		var effects := CardEffectsComponent.new()
		effects.on_play.append(Effect.new())
		card.components.append(effects)
		deck.cards_data.append(card)

	# REVERSE (11)
	for color in range(4):
		deck.cards_quantity.append(2)
		var card := CardData.new()
		card.card_name = "REV"
		card.card_value = Card.CardValue.REVERSE
		card.card_color = color
		var effects := CardEffectsComponent.new()
		effects.on_play.append(Effect.new())
		card.components.append(effects)
		deck.cards_data.append(card)

	# +2 (12)
	for color in range(4):
		deck.cards_quantity.append(2)
		var card := CardData.new()
		card.card_name = "+2"
		card.card_value = Card.CardValue.PLUSTWO
		card.card_color = color
		var effects := CardEffectsComponent.new()
		effects.on_play.append(Effect.new())
		card.components.append(effects)
		deck.cards_data.append(card)

	# +4 (13) — WILD
	deck.cards_quantity.append(4)
	var wild4 := CardData.new()
	wild4.card_name = "+4"
	wild4.card_value = Card.CardValue.PLUSFOUR
	wild4.card_color = Card.CardColor.WILD
	var effects4 := CardEffectsComponent.new()
	effects4.on_play.append(Effect.new())
	effects4.on_play.append(Effect.new())
	wild4.components.append(effects4)
	deck.cards_data.append(wild4)

	ResourceSaver.save(deck, "res://resources/deck_test.tres")
	print("Deck salvo em res://resources/deck_test.tres")
	get_tree().quit()
