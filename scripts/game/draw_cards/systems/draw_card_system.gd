class_name DrawCardSystem
extends System


static func pre_draw_cards(player_id) -> void:
	if NetworkManager.multiplayer.is_server():
		var e_args = PreDrawCardEventArgs.new(player_id)
		var e = PreDrawCardEvent.new(e_args)
		e.start()


static func draw_single_card_data() -> Dictionary:
	var dealer = NetworkManager.game._dealer

	var card_dict: Dictionary = dealer.draw_card_dict()
	if not card_dict.is_empty():
		return card_dict
	return {}


static func draw_single_card(player_id: int, card_dict: Dictionary) -> void:
	var player_entity = NetworkManager.game._players_entities[player_id]
	var player_comp = EntitySystem.get_comp(player_entity, PlayerComponent)
	var dealer = NetworkManager.game._dealer

	if NetworkManager.multiplayer.is_server():
		var card: Card = dealer.draw_card(card_dict["id"], card_dict["entity_id"])
		if card:
			player_comp.hand.add_card(card)
			if player_id != NetworkManager.multiplayer.get_unique_id():
				card.flip(true)
			var e_args = DrawCardEventArgs.new(card.entity)
			var e = DrawCardEvent.new(e_args)
			e.start()
	else:
		var card: Card = dealer.make_card_from_dict(card_dict)
		if card:
			player_comp.hand.add_card(card)
			if player_id != NetworkManager.multiplayer.get_unique_id():
				card.flip(true)


static func draw_card_request(_entity: Entity, comp: DrawOnTriggerComponent) -> void:
	NetworkManager.client_request_action(
		NetworkManager.ActionWhere.GAME,
		GameManager.Actions.DRAW_CARD,
		comp.number_of_cards,
		comp.player
	)
