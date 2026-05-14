class_name ValidationSystem
extends SystemNode

signal action_validated(sender: int, action: String, data: Dictionary)

@export var rule_pack: RulePack

var _game_entity: int = -1


func init_system() -> void:
	Remote.action_received.connect(_pre_validate)
	world.events.on_component_added.connect(_on_component_added)
	replicator.batch_applied.connect(_rebuild_zones)


func _on_component_added(entity: int, type: Script) -> void:
	if type == TurnComponent and _game_entity == -1:
		_game_entity = entity


func _rebuild_zones(_batch: Array[Dictionary] = [], _sync_id: String = "") -> void:
	if not world.entities.exists(_game_entity):
		return
	var gs = world.get_component(_game_entity, GameStateComponent) as GameStateComponent
	if gs:
		gs.rebuild(world)


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
			world.get_component(_game_entity, TurnComponent)
			if world.entities.exists(_game_entity)
			else null
		),
		"stack_component":
		(
			world.get_component(_game_entity, DrawStackComponent)
			if (
				world.entities.exists(_game_entity)
				and world.has_component(_game_entity, DrawStackComponent)
			)
			else null
		),
		"card":
		world.get_component(data.get("entity", -1), CardComponent) if data.has("entity") else null,
		"top_card":
		(
			world.get_component(_get_top_card_entity(999), CardComponent)
			if _get_top_card_entity(999) >= 0
			else null
		)
	}


func _get_top_card_entity(zone_id: int) -> int:
	if not world.entities.exists(_game_entity):
		return -1
	var gs = world.get_component(_game_entity, GameStateComponent) as GameStateComponent
	if not gs:
		return -1
	return gs.get_top_card(zone_id)
