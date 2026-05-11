class_name ColorMatchRule
extends Rule

@export var wild_color: int = 4


func applies_to(action: String, data: Dictionary) -> bool:
	return action == "play_card"


func validate(sender: int, data: Dictionary, context: Dictionary) -> Dictionary:
	var top_card = context.get("top_card") as CardComponent
	var card = context.get("card") as CardComponent
	if not top_card or not card:
		return {"valid": false, "reason": "card data missing"}
	if card.color == wild_color or card.color == top_card.color:
		return {"valid": true}
	return {"valid": false, "reason": "color mismatch"}
