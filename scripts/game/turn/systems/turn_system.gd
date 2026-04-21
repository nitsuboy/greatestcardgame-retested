class_name TurnSystem
extends System


static func change_turn_request(num_of_turns: int) -> void:
	Net.client_request_action(
		Net.multiplayer.get_unique_id(),
		Net.ActionWhere.GAME,
		GameManager.Actions.SKIP_TURN,
		num_of_turns
	)
