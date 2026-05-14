class_name TurnSystem
extends SystemNode

var _game_entity: int = -1
var _seq: int = 0


func init_system() -> void:
	Remote.action_received.connect(_on_action)
	world.events.on_component_added.connect(_check_game_entity)


func _check_game_entity(_entity: int, type: Script) -> void:
	if type == TurnComponent and _game_entity == -1:
		_game_entity = _entity
		print("achou a entidade")


func _on_action(sender: int, action: String, data: Dictionary) -> void:
	if action not in ["end_turn", "skip_turn"]:
		return
	if not multiplayer.is_server():
		return
	if _game_entity == -1:
		return

	var turn = world.get_component(_game_entity, TurnComponent)
	# Server calls are trusted; clients must match current_player
	if sender != multiplayer.get_unique_id() and sender != turn.current_player:
		return
	var player_ids = Players.get_player_ids()
	if player_ids.is_empty():
		return

	if action == "end_turn":
		turn.turn_number += 1
		var idx = player_ids.find(turn.current_player)
		turn.current_player = player_ids[
			(idx + turn.direction + player_ids.size()) % player_ids.size()
		]

	elif action == "skip_turn":
		var amount = data.get("amount", 1)
		var idx = player_ids.find(turn.current_player)
		turn.current_player = player_ids[
			(idx + (turn.direction * amount) + player_ids.size()) % player_ids.size()
		]

	var sync_id = "turn_%d" % _seq
	_seq += 1
	replicator.push_state(
		[{"entity": _game_entity, "type": TurnComponent.resource_path, "data": turn.to_dict()}],
		sync_id
	)
	print(
		"[TurnSystem] _on_action: action=",
		action,
		" _game_entity=",
		_game_entity,
		" data=",
		turn.to_dict()
	)
