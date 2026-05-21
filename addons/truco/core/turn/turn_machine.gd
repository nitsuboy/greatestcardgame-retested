## Generic turn engine for card games.
##
## Controls card locks (prevents interaction outside turn),
## active player hand visibility, and turn phases.
##
## Virtual methods (override in subclass):
## - _is_action_phase(phase) → bool
## - _on_activate_player_hand(player)
## - _on_deactivate_player_hand(player)
## - _on_phase_arrived(phase)
class_name TurnMachine
extends SystemNode

var _game_entity: int = -1
var _turn_comp_type: Script
var _seq: int = 0

## Emitted when the game entity is detected.
signal game_entity_ready(entity: int)
## Emitted when the turn phase changes.
signal phase_changed(old_phase: int, new_phase: int)


func init_system() -> void:
	world.events.on_game_entity_ready.connect(_on_game_entity_ready)
	replicator.batch_applied.connect(_on_batch_applied)


func _on_game_entity_ready(entity: int) -> void:
	_game_entity = entity
	game_entity_ready.emit(entity)


func _on_batch_applied(batch: Array[Dictionary], _sync_id: String) -> void:
	if _game_entity == -1 or not world.entities.exists(_game_entity):
		return

	var found := false
	for entry in batch:
		if _turn_comp_type and entry.type == _turn_comp_type.resource_path:
			found = true
			break

	if not found:
		return

	var turn = _get_turn_component()
	if not turn:
		return

	_update_card_locks(turn.current_player, turn.phase)
	_update_hand_visibility(turn.current_player)
	_on_phase_arrived(turn.phase)


func _get_turn_component():
	return world.get_component(_game_entity, _turn_comp_type)


# ── Card locks (generic) ─────────────────────────────────────


func _update_card_locks(current_player: int, phase: int) -> void:
	var my_id := multiplayer.get_unique_id()
	var is_action := _is_action_phase(phase)

	world.query([CardComponent, DraggableComponent, HoverableComponent]).for_each(
		func(_e, comps):
			var locked: bool = not (
				is_action and current_player == my_id and comps[0].zone_id == my_id
			)
			comps[1].locked = locked
			comps[2].locked = locked
	)


# ── Hand visibility (virtual hook) ───────────────────────────


func _update_hand_visibility(current_player: int) -> void:
	world.query([PlayerComponent]).for_each(
		func(_e, comps):
			if current_player == comps[0].peer_id:
				_on_activate_player_hand(comps[0])
			else:
				_on_deactivate_player_hand(comps[0])
	)


# ── Virtual methods (override in subclass) ───────────────────


func _is_action_phase(_phase: int) -> bool:
	return false


func _on_activate_player_hand(_player: PlayerComponent) -> void:
	pass


func _on_deactivate_player_hand(_player: PlayerComponent) -> void:
	pass


func _on_phase_arrived(_phase: int) -> void:
	pass


# ── Utilities ────────────────────────────────────────────────


func set_phase(phase: int) -> void:
	var turn = _get_turn_component()
	if not turn:
		return
	var old = turn.phase
	turn.phase = phase
	_push_turn_component("phase")
	phase_changed.emit(old, phase)


func phase_delay(seconds: float) -> void:
	if not multiplayer.is_server():
		return
	await get_tree().create_timer(seconds).timeout


func get_current_player() -> int:
	var turn = _get_turn_component()
	return turn.current_player if turn else -1


func advance_next_player(player_ids: Array, current: int, direction: int, skip: int) -> int:
	var steps := 1 + skip
	var idx := player_ids.find(current)
	if idx < 0:
		idx = 0
	return player_ids[(idx + direction * steps + player_ids.size() * 10) % player_ids.size()]


func _push_turn_component(prefix: String) -> void:
	var turn = _get_turn_component()
	if not turn:
		return
	var sync_id := "%s_%d" % [prefix, _seq]
	_seq += 1
	replicator.push_state(
		[{"entity": _game_entity, "type": _turn_comp_type.resource_path, "data": turn.to_dict()}],
		sync_id
	)
