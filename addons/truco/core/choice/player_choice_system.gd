## Generic system for requesting choices from players.
##
## The server requests a choice via request_choice(), and the player
## responds via RemoteAction. If the timeout expires, a default choice
## is used automatically.
class_name PlayerChoiceSystem
extends SystemNode

## Emitted when the player responds (or timeout).
signal choice_received(sender: int, request_id: String, choice: Variant)
## Emitted on the server when a choice is requested.
signal choice_requested(player_id: int, request_id: String, type: String, data: Dictionary)
## Emitted on the client to open the choice UI.
signal choice_ui_requested(request_id: String, type: String, data: Dictionary)

## Maximum wait time for a response (seconds).
@export var timeout: float = 30.0

var _pending_requests: Dictionary = {}
var _seq: int = 0


func init_system() -> void:
	Remote.action_received.connect(_on_action)


func _process(delta: float) -> void:
	var expired: Array[String] = []
	for rid in _pending_requests:
		_pending_requests[rid].time += delta
		if _pending_requests[rid].time >= timeout:
			expired.append(rid)
	for rid in expired:
		var req = _pending_requests[rid]
		var default_choice = _default_choice(req.type)
		choice_received.emit(req.player, rid, default_choice)
		_pending_requests.erase(rid)


## Requests a choice from a player. type defines the choice type.
func request_choice(player_id: int, type: String, data: Dictionary = {}) -> void:
	if not multiplayer.is_server():
		return
	var request_id = "%s_%d_%d" % [type, _seq, player_id]
	_seq += 1
	_pending_requests[request_id] = {"player": player_id, "type": type, "data": data, "time": 0.0}
	choice_requested.emit(player_id, request_id, type, data)
	if player_id >= 0:
		_rpc_open_choice.rpc_id(player_id, request_id, type, data)


func _on_action(sender: int, action: String, data: Dictionary) -> void:
	if action != "choice_response":
		return
	if not multiplayer.is_server():
		return

	var request_id = data.get("request_id", "")
	var req = _pending_requests.get(request_id)
	if not req or req.player != sender:
		return
	choice_received.emit(sender, request_id, data.get("choice"))
	_pending_requests.erase(request_id)


## Default choice when timeout is reached.
func _default_choice(type: String) -> Variant:
	match type:
		"color":
			return 0
		"target_player":
			var ids = Players.get_player_ids()
			return ids[0] if ids.size() > 0 else -1
		_:
			return true


@rpc("authority", "call_local", "reliable")
func _rpc_open_choice(request_id: String, type: String, data: Dictionary) -> void:
	choice_ui_requested.emit(request_id, type, data)
