class_name ZoneRule
extends Rule


func applies_to(action: String, _data: Dictionary) -> bool:
	return action == "play_card"


func validate(_sender: int, data: Dictionary, _context: Dictionary) -> Dictionary:
	var zone: int = data.get("zone", 999)
	if zone != 999:
		return {"valid": false, "reason": "só pode jogar carta no descarte (zone 999)"}
	return {"valid": true}
