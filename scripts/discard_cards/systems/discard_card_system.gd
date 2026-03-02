class_name DiscardCardSystem
extends System


static func try_discard_card(
	entity: Entity, _comp: DiscardableComponent, event_args: DropEventArgs
) -> void:
	var dropzone = event_args.drop_zone

	if EntitySystem.has_comp(dropzone.entity, DiscardZoneComponent):
		NetworkManager.request_action(1, 0, entity.id, dropzone.entity.id)


static func discard_card(entity: Entity, _comp: Component) -> void:
	var dealer = NetworkManager.game._dealer
	dealer.discard_card(_comp.node)

	if NetworkManager.multiplayer.is_server():
		var e_args = DiscardCardEventArgs.new(entity)
		var e = DiscardCardEvent.new(e_args)
		e.start()
	print("discard feito")


static func discard_card_triggered(
	entity: Entity, _comp: Component, _event_args: EventArgs
) -> void:
	print("discard trigger ativado")
	if NetworkManager.multiplayer.is_server():
		NetworkManager.request_action(
			NetworkManager.ActionWhere.GAME, GameManager.Actions.DISCARD_CARD, entity.id
		)
		return
	NetworkManager.request_action.rpc_id(
		1, NetworkManager.ActionWhere.GAME, GameManager.Actions.DISCARD_CARD, entity.id
	)
