class_name DrawStackRule
extends Rule


func applies_to(action: String, data: Dictionary) -> bool:
	return action == "play_card"


func validate(sender: int, data: Dictionary, context: Dictionary) -> Dictionary:
	var stack_comp = context.get("stack_component") as DrawStackComponent
	if not stack_comp or stack_comp.accumulated <= 0:
		return {"valid": true}
	# Se stack > 0, só pode jogar +2 (value=12) ou +4 (value=13)
	var card = context.get("card") as CardComponent
	if card and (card.value == 12 or card.value == 13):
		return {"valid": true}
	return {"valid": false, "reason": "draw stack active, need +2 or +4"}
