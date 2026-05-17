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
		world.events.on_component_added.disconnect(_on_component_added)


func _rebuild_zones(_batch: Array[Dictionary] = [], _sync_id: String = "") -> void:
	var needs_rebuild := false
	for entry in _batch:
		if entry.type == CardComponent.resource_path:
			needs_rebuild = true
			break
	if not needs_rebuild:
		return
	if not world.entities.exists(_game_entity):
		return
	var gs = world.get_component(_game_entity, GameStateComponent) as GameStateComponent
	if gs:
		gs.apply_batch(_batch)


func _pre_validate(sender: int, action: String, data: Dictionary) -> void:
	if action == "start_game":
		return
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
	var turn_comp := world.get_component(_game_entity, TurnComponent) as TurnComponent

	return {
		"world": world,
		"turn_component": turn_comp,
		"stack_component":
		(
			world.get_component(_game_entity, DrawStackComponent)
			if world.entities.exists(_game_entity)
			else null
		),
		"card":
		world.get_component(data.get("entity", -1), CardComponent) if data.has("entity") else null,
		"uno_card":
		(
			world.get_component(data.get("entity", -1), UnoCardComponent)
			if data.has("entity")
			else null
		),
		"top_card":
		(
			world.get_component(_get_top_card_entity(999), CardComponent)
			if _get_top_card_entity(999) >= 0
			else null
		),
		"top_uno_card":
		(
			world.get_component(_get_top_card_entity(999), UnoCardComponent)
			if _get_top_card_entity(999) >= 0
			else null
		),
		"phase": turn_comp.phase if turn_comp else -1,
		"draw_config":
		(
			world.get_component(_game_entity, DrawConfigComponent)
			if world.entities.exists(_game_entity)
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


func player_has_playable(player_id: int) -> bool:
	if not rule_pack:
		return true

	var gs := world.get_component(_game_entity, GameStateComponent) as GameStateComponent
	if not gs:
		return false

	var cards_ids := gs.get_cards_in_zone(player_id)
	for cid in cards_ids:
		var card := world.get_component(cid, CardComponent) as CardComponent
		if not card:
			continue

		var data = {"entity": cid}
		var context = _build_context(data)
		context.phase = TurnSequenceSystem.Phase.PLAYER_ACTION
		var valid = true
		for rule in rule_pack.rules:
			if not rule.applies_to("play_card", data):
				continue
			if not rule.validate(player_id, data, context).valid:
				valid = false
				break
		if valid:
			return true

	return false


func get_playable_cards(player_id: int) -> Array[int]:
	var gs := world.get_component(_game_entity, GameStateComponent) as GameStateComponent
	if not gs:
		return []

	var cards_ids := gs.get_cards_in_zone(player_id)
	var playable: Array[int] = []

	for cid in cards_ids:
		var card := world.get_component(cid, CardComponent) as CardComponent
		if not card:
			continue

		var data = {"entity": cid}
		var context = _build_context(data)
		context.phase = TurnSequenceSystem.Phase.PLAYER_ACTION
		var valid = true
		for rule in rule_pack.rules:
			if not rule.applies_to("play_card", data):
				continue
			if not rule.validate(player_id, data, context).valid:
				valid = false
				break
		if valid:
			playable.append(cid)

	return playable
