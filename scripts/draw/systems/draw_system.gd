class_name DrawSystem
extends System


static func draw_card(_entity: Entity, comp: Component, _args: EventArgs) -> void:
	if NetworkManager.multiplayer.is_server():
		NetworkManager.request_action(NetworkManager.ActionWhere.GAME, 2, comp.number_of_cards)
		return
	NetworkManager.request_action(NetworkManager.ActionWhere.GAME, 2, comp.number_of_cards)

static func draw_card_triggered(
	_entity: Entity, comp: Component, _event_args: EventArgs
) -> void:
	if NetworkManager.multiplayer.is_server():
		NetworkManager.request_action(NetworkManager.ActionWhere.GAME, 
									  GameManager.Actions.DRAW_CARD,
									  comp.number_of_cards)
		return
	NetworkManager.request_action.rpc_id(1,
										 NetworkManager.ActionWhere.GAME, 
										 GameManager.Actions.DRAW_CARD, 
										 comp.number_of_cards)
