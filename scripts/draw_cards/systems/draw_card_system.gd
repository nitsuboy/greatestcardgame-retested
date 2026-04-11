class_name DrawCardSystem
extends System


static func pre_draw_cards(player_id) -> void:
	if NetworkManager.multiplayer.is_server():
		var e_args = PreDrawCardEventArgs.new(player_id)
		var e = PreDrawCardEvent.new(e_args)
		e.start()


static func draw_cards(player_id, num_cards) -> Array:
	var players_nodes = NetworkManager.game._players_nodes
	var dealer = NetworkManager.game._dealer
	var player = players_nodes[player_id]
	var hand_cards = []
	for i in range(num_cards):
		var card: Card = dealer.draw_card()
		if card:
			player.add_card(card)
			hand_cards.append([card.card_data.id, card.entity.id])
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
