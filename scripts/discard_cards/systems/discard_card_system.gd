class_name DiscardCardSystem
extends System

# esse sistema todo provavelmente precisa de uma refatoração


static func try_discard_card(
	entity: Entity, _comp: DiscardableComponent, event_args: DropEventArgs
) -> void:
	var dropzone = event_args.drop_zone

	if EntitySystem.has_comp(dropzone.entity, DiscardZoneComponent):
		NetworkManager.request_action(1, 0, entity.id, dropzone.entity.id)  # TODO: colocar os enums aqui


static func discard_card(entity: Entity, _comp: NodeComponent) -> void:  # TODO: substituir com `comp: DiscardableComponent`
	var dealer = NetworkManager.game._dealer
	dealer.discard_card(_comp.node)

	if NetworkManager.multiplayer.is_server():
		var e_args = DiscardCardEventArgs.new(entity)
		var e = DiscardCardEvent.new(e_args)
		e.start()
	print("discard feito")


static func discard_card_request(entity: Entity) -> void:  # TODO: adicionar `comp: DiscardableComponent`
	if NetworkManager.multiplayer.is_server():
		NetworkManager.request_action(
			NetworkManager.ActionWhere.GAME, GameManager.Actions.DISCARD_CARD, entity.id
		)
		return
	NetworkManager.request_action.rpc_id(
		1, NetworkManager.ActionWhere.GAME, GameManager.Actions.DISCARD_CARD, entity.id
	)
