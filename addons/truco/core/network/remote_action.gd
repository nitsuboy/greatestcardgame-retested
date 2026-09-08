## Abstraction for sending named actions via RPC.
##
## Clients send actions to the server, which routes them locally.
## Simplifies RPC usage for game actions.
## Registered as global autoload (Remote).
class_name RemoteAction
extends Node

## Emitted when an action is received by the server.
signal action_received(sender_id: int, action: String, data: Dictionary)

var _handlers: Dictionary = {}


func on(action: String, callable: Callable) -> void:
	if not _handlers.has(action):
		_handlers[action] = []
	_handlers[action].append(callable)


func off(action: String, callable: Callable) -> void:
	if _handlers.has(action):
		_handlers[action].erase(callable)


## Sends a named action. If server, routes locally.
func send(action: String, data: Dictionary = {}) -> void:
	if multiplayer.is_server():
		_dispatch(multiplayer.get_unique_id(), action, data)
	else:
		_rpc_send.rpc_id(1, multiplayer.get_unique_id(), action, data)


func broadcast(action: String, data: Dictionary = {}) -> void:
	if not multiplayer.is_server():
		return
	_rpc_broadcast.rpc(action, data)


func send_to(peer_id: int, action: String, data: Dictionary = {}) -> void:
	if not multiplayer.is_server():
		return
	if peer_id == multiplayer.get_unique_id():
		_dispatch(peer_id, action, data)
	else:
		_rpc_send_to.rpc_id(peer_id, action, data)


@rpc("any_peer", "call_local", "reliable")
func _rpc_send(sender_id: int, action: String, data: Dictionary) -> void:
	if not multiplayer.is_server():
		return
	_dispatch(sender_id, action, data)


@rpc("authority", "call_local", "reliable")
func _rpc_broadcast(action: String, data: Dictionary) -> void:
	var sender := data.get("_sender", multiplayer.get_unique_id())
	_dispatch(sender, action, data)


@rpc("authority", "reliable")
func _rpc_send_to(action: String, data: Dictionary) -> void:
	_dispatch(multiplayer.get_unique_id(), action, data)


func _dispatch(sender: int, action: String, data: Dictionary) -> void:
	if _handlers.has(action):
		for c in _handlers[action]:
			c.call(sender, data)
	action_received.emit(sender, action, data)
