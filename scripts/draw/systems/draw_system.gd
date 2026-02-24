class_name DrawSystem
extends System

static func request_draw(entity: Entity, comp: Component, args:EventArgs) -> void:
	if NetworkManager.multiplayer.is_server():
		NetworkManager.request_action(
			NetworkManager.ActionWhere.GAME,
			 2, comp.number_of_cards)
		return
	NetworkManager.request_action(
		NetworkManager.ActionWhere.GAME,
		 2, comp.number_of_cards)
