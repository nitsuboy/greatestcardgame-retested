class_name DrawCardSystem
extends System


# static func pre_draw_cards(player_id) -> void:
#	if Net.multiplayer.is_server():
#		var ev = PreDrawCardEvent.new(player_id)
#		EventSystem.IniciarEventoLocal(card_entity, ev) # para iniciar o evento precisa da entidade da carta


static func draw_single_card_data() -> Dictionary:
	var game = Net.game
	var dealer = game.get_dealer()

	var card_dict: Dictionary = dealer.draw_card_dict()
	if not card_dict.is_empty():
		return card_dict
	return {}


static func draw_single_card(player_id: int, card_dict: Dictionary) -> void:
	var game = Net.game
	var player_entity = game.get_player_entity(player_id)
	var player_comp = EntitySystem.get_comp(player_entity, PlayerComponent)
	var dealer = game.get_dealer()

	if game.is_server():
		var card: Card = dealer.draw_card(card_dict["id"], card_dict["entity_id"])
		if card:
			player_comp.hand.add_card(card)
			if player_id != Net.multiplayer.get_unique_id():
				card.flip(true)
			var e_args = DrawCardEventArgs.new(card.entity)
			var e = DrawCardEvent.new(e_args)
			e.start()
	else:
		var card: Card = dealer.make_card_from_dict(card_dict)
		if card:
			player_comp.hand.add_card(card)
			if player_id != Net.multiplayer.get_unique_id():
				card.flip(true)
