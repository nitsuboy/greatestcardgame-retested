class_name DrawCardSystem
extends System


static func pre_draw_cards(player_id) -> void:
	if NetworkManager.multiplayer.is_server():
		var e_args = PreDrawCardEventArgs.new(player_id)
		var e = PreDrawCardEvent.new(e_args)
		e.start()


static func draw_single_card_data() -> Dictionary:
	var dealer = NetworkManager.game._dealer

	var card: Card = dealer.draw_card()
	if card:
		return {"id": card.card_data.id, "entity_id": card.entity.id}
	return {}


static func draw_single_card(player_id: int) -> Dictionary:
	var player_entity = NetworkManager.game._players_entities[player_id]
	var player_comp = EntitySystem.get_comp(player_entity, PlayerComponent)
	var dealer = NetworkManager.game._dealer

	var card: Card = dealer.draw_card()
	if card:
		player_comp.hand.add_card(card)

		if player_id != NetworkManager.multiplayer.get_unique_id():
			card.flip(true)

		if NetworkManager.multiplayer.is_server():
			var e_args = DrawCardEventArgs.new(card.entity)
			var e = DrawCardEvent.new(e_args)
			e.start()

		return {"id": card.card_data.id, "entity_id": card.entity.id}

	return {}


static func draw_cards(player_id, num_cards) -> Array:
	var player_entity = NetworkManager.game._players_entities[player_id]
	var player_comp = EntitySystem.get_comp(player_entity, PlayerComponent)
	var dealer = NetworkManager.game._dealer
	var hand_cards = []
	for i in range(num_cards):
		var card: Card = dealer.draw_card()
		if card:
			player_comp.hand.add_card(card)
			hand_cards.append({"id": card.card_data.id, "entity_id": card.entity.id})
			if player_id != NetworkManager.multiplayer.get_unique_id():
				card.flip(true)
			if NetworkManager.multiplayer.is_server():
				var e_args = DrawCardEventArgs.new(card.entity)
				var e = DrawCardEvent.new(e_args)
				e.start()
	return hand_cards


static func draw_card_request(_entity: Entity, comp: DrawOnTriggerComponent) -> void:
	NetworkManager.client_request_action(
		NetworkManager.ActionWhere.GAME,
		GameManager.Actions.DRAW_CARD,
		comp.number_of_cards,
		comp.player
	)
