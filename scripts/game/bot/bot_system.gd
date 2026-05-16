class_name BotSystem
extends SystemNode

var _bot_ids: Array[int] = []
var _game_entity: int = -1
var _action_pending: bool = false


func init_system() -> void:
	world.events.on_component_added.connect(_check_game_entity)
	replicator.batch_applied.connect(_on_batch_applied)
	world.events.on_component_added.connect(_on_player_added)

	var pcs = world.get_system(PlayerChoiceSystem)
	if pcs:
		pcs.choice_requested.connect(_on_choice_requested)


func _on_player_added(entity: int, type: Script) -> void:
	if type == PlayerComponent:
		var pc = world.get_component(entity, PlayerComponent) as PlayerComponent
		if pc and pc.is_bot:
			_bot_ids.append(pc.peer_id)


func _check_game_entity(entity: int, type: Script) -> void:
	if type == TurnComponent and _game_entity == -1:
		_game_entity = entity
		world.events.on_component_added.disconnect(_check_game_entity)


func _on_batch_applied(batch: Array[Dictionary], _sync_id: String) -> void:
	if _game_entity == -1 or not multiplayer.is_server() or _bot_ids.is_empty():
		return

	for entry in batch:
		if entry.type == TurnComponent.resource_path:
			var turn = world.get_component(_game_entity, TurnComponent) as TurnComponent
			if (
				turn
				and turn.phase == TurnSequenceSystem.Phase.PLAYER_ACTION
				and turn.current_player in _bot_ids
			):
				_execute_bot_turn(turn.current_player)


func _execute_bot_turn(player_id: int) -> void:
	if _action_pending:
		return
	_action_pending = true

	await get_tree().create_timer(0.5).timeout

	if not world.entities.exists(_game_entity):
		_action_pending = false
		return

	var vs = world.get_system(ValidationSystem)
	if vs:
		var playable = (
			vs.get_playable_cards(player_id) if vs.rule_pack else _get_all_hand_cards(player_id)
		)
		if not playable.is_empty():
			playable.shuffle()
			Remote.action_received.emit(
				player_id, "play_card", {"entity": playable[0], "zone": 999}
			)
			_action_pending = false
			return

	Remote.action_received.emit(player_id, "draw_card", {})
	_action_pending = false


func _get_all_hand_cards(player_id: int) -> Array[int]:
	var gs = world.get_component(_game_entity, GameStateComponent) as GameStateComponent
	return gs.get_cards_in_zone(player_id) if gs else []


func _on_choice_requested(
	player_id: int, request_id: String, type: String, _data: Dictionary
) -> void:
	if player_id not in _bot_ids:
		return

	var choice: Variant
	match type:
		"color":
			choice = randi() % 4
		"target_player":
			var ids = Players.get_player_ids()
			var filtered = ids.filter(func(id): return id != player_id and id not in _bot_ids)
			choice = filtered[0] if filtered else (ids[0] if ids else 0)
		_:
			choice = true

	# Aguarda _resolve_played_card executar primeiro (PLAY_CARD_DELAY = 0.2s)
	await get_tree().create_timer(0.3).timeout

	_emit_choice_response(player_id, request_id, choice)
	print("BotSystem: bot %d escolheu %s=%s" % [player_id, type, str(choice)])


func _emit_choice_response(player_id: int, request_id: String, choice: Variant) -> void:
	Remote.action_received.emit(
		player_id, "choice_response", {"request_id": request_id, "choice": choice}
	)
