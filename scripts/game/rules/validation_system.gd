class_name ValidationSystem
extends SystemNode

signal action_validated(sender: int, action: String, data: Dictionary)

@export var rule_pack: RulePack

var _turn_entity: int = -1
var _top_card_entity: int = -1


func init_system() -> void:
	Remote.action_received.connect(_pre_validate)
	world.events.on_component_added.connect(_on_component_added)


func _on_component_added(entity: int, type: Script) -> void:
	if type == TurnComponent and _turn_entity == -1:
		_turn_entity = entity
	if type == CardComponent and _top_card_entity == -1:
		_top_card_entity = entity


func _pre_validate(sender: int, action: String, data: Dictionary) -> void:
	if not multiplayer.is_server():
		return
	if not rule_pack:
		action_validated.emit(sender, action, data)
		return

	var context = _build_context(data)
	for rule in rule_pack.rules:
		if not rule.applies_to(action, data):
			continue
		var result = rule.validate(sender, data, context)
		if not result.valid:
			Remote.send(
				"action_rejected",
				{"action": action, "reason": result.reason, "original_data": data}
			)
			return

	action_validated.emit(sender, action, data)


func _build_context(data: Dictionary) -> Dictionary:
	return {
		"world": world,
		"turn_component":
		(
			world.get_component(_turn_entity, TurnComponent)
			if world.entities.exists(_turn_entity)
			else null
		),
		"stack_component":
		(
			world.get_component(_turn_entity, DrawStackComponent)
			if (
				world.entities.exists(_turn_entity)
				and world.has_component(_turn_entity, DrawStackComponent)
			)
			else null
		),
		"card":
		world.get_component(data.get("entity", -1), CardComponent) if data.has("entity") else null,
		"top_card":
		(
			world.get_component(_top_card_entity, CardComponent)
			if world.entities.exists(_top_card_entity)
			else null
		)
	}
