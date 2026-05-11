class_name TurnRule
extends Rule


func applies_to(action: String, data: Dictionary) -> bool:
	return action in ["play_card", "discard_card", "end_turn"]


func validate(sender: int, data: Dictionary, context: Dictionary) -> Dictionary:
	var turn_comp = context.get("turn_component") as TurnComponent
	if not turn_comp:
		return {"valid": false, "reason": "turn not initialized"}
	if turn_comp.current_player != sender:
		return {"valid": false, "reason": "not your turn"}
	return {"valid": true}
