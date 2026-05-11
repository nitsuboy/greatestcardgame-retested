class_name ValueMatchRule
extends Rule


func applies_to(action: String, data: Dictionary) -> bool:
	return action == "play_card"


func validate(sender: int, data: Dictionary, context: Dictionary) -> Dictionary:
	var top_card = context.get("top_card") as CardComponent
	var card = context.get("card") as CardComponent
	if not top_card or not card:
		return {"valid": false, "reason": "card data missing"}
	if card.value == top_card.value:
		return {"valid": true}
	return {"valid": false, "reason": "value mismatch"}
