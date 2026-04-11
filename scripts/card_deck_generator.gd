extends Node


func _ready() -> void:
	# Cria o deck
	var deck: CardDeck = load("res://scripts/cards/card_deck.gd").new()
	var draggable = load("res://scripts/dragging/components/draggable_component.gd")
	var hoverable = load("res://scripts/hover/components/hoverble_component.gd")
	var playable = load("res://scripts/play_cards/components/playable_component.gd")
	var tonp = load("res://scripts/play_cards/components/trigger_on_played_component.gd")
	var skip = load("res://scripts/turn/components/skip_turn_on_trigger_component.gd")
	var card_l = load("res://scripts/cards/card_data.gd")
	# Cria algumas cartas
	for i in range(15):
		if i < 13:
			for c in range(4):
				if i == 0:
					deck.cards_quantity.append(1)
				else:
					deck.cards_quantity.append(2)

				var card: CardData = card_l.new()
				match str(i):
					"10":
						card.card_name = "SKP"
					"11":
						card.card_name = "REV"
					"12":
						card.card_name = "+2"
					_:
						card.card_name = str(i)

				# Adiciona componentes
				var draggable_comp: DraggableComponent = draggable.new()
				var hoverable_comp: HoverbleComponent = hoverable.new()
				var playable_comp: PlayableComponent = playable.new()
				var tonplayable_comp: TriggerOnPlayedComponent = tonp.new()
				var skiptur: SkipTurnOnTriggerComponent = skip.new()
				card.card_color = c
				card.card_value = i

				card.components.append(draggable_comp)
				card.components.append(hoverable_comp)
				card.components.append(playable_comp)
				card.components.append(tonplayable_comp)
				card.components.append(skiptur)

				# Adiciona carta ao deck
				deck.cards_data.append(card)
		else:
			deck.cards_quantity.append(4)
			var card = card_l.new()
			# Adiciona componentes
			var draggable_comp: DraggableComponent = draggable.new()
			var hoverable_comp: HoverbleComponent = hoverable.new()
			var playable_comp: PlayableComponent = playable.new()
			match str(i):
				"13":
					card.card_name = "+4"
					card.card_value = i
				"14":
					card.card_name = ""
					card.card_value = -1

			card.card_color = 4

			card.components.append(draggable_comp)
			card.components.append(hoverable_comp)
			card.components.append(playable_comp)

			# Adiciona carta ao deck
			deck.cards_data.append(card)

	# Salva o recurso em disco
	ResourceSaver.save(deck, "res://resources/deck.tres")
