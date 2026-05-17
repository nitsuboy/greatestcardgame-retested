class_name PhaseRule
extends Rule


func applies_to(action: String, _data: Dictionary) -> bool:
	return action in ["play_card", "draw_card"]


func validate(_sender: int, _data: Dictionary, context: Dictionary) -> Dictionary:
	var phase = context.get("phase", -1)
	if phase != TurnSequenceSystem.Phase.PLAYER_ACTION:
		return {"valid": false, "reason": "action not allowed in current phase"}
	return {"valid": true}
