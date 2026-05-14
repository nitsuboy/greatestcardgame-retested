class_name TurnSystem
extends SystemNode

var _turn_entity: int = -1
var _seq: int = 0


func init_system() -> void:
	Remote.action_received.connect(_on_action)
	world.events.on_component_added.connect(_check_turn_entity)


func _check_turn_entity(_entity: int, type: Script) -> void:
	if type == TurnComponent and _turn_entity == -1:
		_turn_entity = _entity
		print("achou a entidade")


func _on_action(sender: int, action: String, data: Dictionary) -> void:
	if action not in ["end_turn", "skip_turn"]:
		return
	if not multiplayer.is_server():
		return
	if _turn_entity == -1:
		return

	var turn = world.get_component(_turn_entity, TurnComponent)
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
		[{"entity": _turn_entity, "type": TurnComponent.resource_path, "data": turn.to_dict()}],
		sync_id
	)
	print(
		"[TurnSystem] _on_action: action=",
		action,
		" _turn_entity=",
		_turn_entity,
		" data=",
		turn.to_dict()
	)
