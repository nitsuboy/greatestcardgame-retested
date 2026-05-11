class_name Rule
extends Resource


func applies_to(action: String, data: Dictionary) -> bool:
	return false


func validate(sender: int, data: Dictionary, context: Dictionary) -> Dictionary:
	return {"valid": true, "reason": ""}
