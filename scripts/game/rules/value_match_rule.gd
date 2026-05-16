class_name ValueMatchRule
extends Rule


func applies_to(action: String, _data: Dictionary) -> bool:
	return action == "play_card"


func validate(_sender: int, _data: Dictionary, context: Dictionary) -> Dictionary:
	var top_card = context.get("top_card") as CardComponent
	var card = context.get("card") as CardComponent
	if not card:
		return {"valid": false, "reason": "card data missing"}
	if not top_card or card.value == top_card.value:
		return {"valid": true}
	return {"valid": false, "reason": "value mismatch"}
