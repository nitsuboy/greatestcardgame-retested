class_name DrawCardSystem
extends System


static func initialize():
	EventSystem.inscrever_evento_global(
		DrawOtherCardEvent, Callable(DrawCardSystem, "on_other_card_drawn")
	)

	EventSystem.inscrever_evento_local(
		DrawOnTriggerComponent, TriggerEvent, Callable(DrawCardSystem, "on_trigger")
	)


static func on_other_card_drawn(_args: DrawOtherCardEvent):
	# TODO: usar um query aqui
	for entity in EntityRegistry.get_all_entities().values():
		if EntitySystem.has_comp(entity, TriggerOnOtherCardDrawComponent):
			var ev = DrawOtherCardEvent.new(_args.drawn_card, _args.player_id)
			EventSystem.iniciar_evento_local(entity, ev)


static func on_trigger(_entity: Entity, _comp: DrawOnTriggerComponent, _args: TriggerEvent):
	if not _comp.keys_in.has(_args.key_out):
		return
	var game = Net.game
	var action = TriggerSystem.TriggerAction.new(
		game.search_player(_comp.player),
		GameManager.Actions.DRAW_CARD,
		[_comp.number_of_cards, _comp.player]
	)
	Net.enqueue_trigger_action(action)
	print(
		(
			"    [ENQUEUED] DRAW_CARD | Cards: %d | Target offset: %d"
			% [_comp.number_of_cards, _comp.player]
		)
	)


# static func pre_draw_cards(player_id) -> void:
#	if Net.multiplayer.is_server():
#		var ev = PreDrawCardEvent.new(player_id)
#		EventSystem.iniciar_evento_local(card_entity, ev)
# para iniciar o evento precisa da entidade da carta


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

	var card: Card

	if game.is_server():
		card = dealer.draw_card(card_dict["id"], card_dict["entity_id"])
	else:
		card = dealer.make_card_from_dict(card_dict)

	if card:
		_add_card_to_hand(card, player_comp, player_id == Net.multiplayer.get_unique_id())

		if game.is_server():
			_fire_draw_events(card.entity, player_id)


static func _add_card_to_hand(card: Card, player_comp, is_owner: bool) -> void:
	player_comp.hand.add_card(card)
	if not is_owner:
		card.flip(true)


static func _fire_draw_events(card_entity: Entity, player_id: int) -> void:
	var ev = DrawCardEvent.new(player_id)
	EventSystem.iniciar_evento_local(card_entity, ev)

	var other_ev = DrawOtherCardEvent.new(card_entity, player_id)
	EventSystem.iniciar_evento_global(other_ev)
