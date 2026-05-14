class_name BasicMatchRule
extends Rule

@export var wild_color: int = 4


func applies_to(action: String, data: Dictionary) -> bool:
	return action == "play_card"


func validate(sender: int, data: Dictionary, context: Dictionary) -> Dictionary:
	var top_card = context.get("top_card") as CardComponent
	var card = context.get("card") as CardComponent
	if not card:
		return {"valid": false, "reason": "card data missing"}
	if not top_card:
		return {"valid": true}
	if card.color == wild_color or card.color == top_card.color or card.value == top_card.value:
		return {"valid": true}
	return {"valid": false, "reason": "card doesn't match top card"}
