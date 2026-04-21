class_name TurnSystem
extends System


static func change_turn_request(num_of_turns: int) -> void:
	NetworkManager.client_request_action(
		NetworkManager.multiplayer.get_unique_id(),
		NetworkManager.ActionWhere.GAME,
		GameManager.Actions.SKIP_TURN,
		num_of_turns
	)
