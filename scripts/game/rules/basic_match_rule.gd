class_name BasicMatchRule
extends Rule

@export var wild_color: int = 4


func applies_to(action: String, _data: Dictionary) -> bool:
	return action == "play_card"


func validate(_sender: int, _data: Dictionary, context: Dictionary) -> Dictionary:
	var uno_card = context.get("uno_card") as UnoCardComponent
	var top_uno_card = context.get("top_uno_card") as UnoCardComponent
	var stack_comp = context.get("stack_component") as DrawStackComponent
	if not uno_card:
		return {"valid": false, "reason": "card data missing"}
	if not top_uno_card:
		return {"valid": true}
	if (
		uno_card.color == wild_color
		or uno_card.color == top_uno_card.color
		or uno_card.value == top_uno_card.value
	):
		return {"valid": true}
	if (
		stack_comp.accumulated > 0
		and (uno_card.value == Card.CardValue.PLUSTWO or uno_card.value == Card.CardValue.PLUSFOUR)
	):
		return {"valid": true}
	return {"valid": false, "reason": "card doesn't match top card"}
