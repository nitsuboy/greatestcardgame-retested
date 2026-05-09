class_name CardData
extends Resource

@export var card_name: String = "Nova Carta"
@export var components: Array[Resource]
@export var card_value: Card.CardValue
@export var card_color: Card.CardColor
var id = -1


func to_dict() -> Dictionary:
	var comps = []
	for c in components:
		if (c is TriggerOnComponent) or (c is OnTriggerComponent):
			continue
		comps.append(
			{"type": c.get_script().get_global_name(), "data": EntitySystem.component_to_dict(c)}
		)
	return {
		"id": id, "name": card_name, "value": card_value, "color": card_color, "components": comps
	}
