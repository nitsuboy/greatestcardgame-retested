## Abstraction for sending named actions via RPC.
##
## Clients send actions to the server, which routes them locally.
## Simplifies RPC usage for game actions.
## Registered as global autoload (Remote).
class_name RemoteAction
extends Node

## Emitted when an action is received by the server.
signal action_received(sender_id: int, action: String, data: Dictionary)


## Sends a named action. If server, routes locally.
func send(action: String, data: Dictionary = {}) -> void:
	if multiplayer.is_server():
		_route(multiplayer.get_unique_id(), action, data)
	else:
		_rpc_send.rpc_id(1, multiplayer.get_unique_id(), action, data)


@rpc("any_peer", "call_local", "reliable")
func _rpc_send(sender_id: int, action: String, data: Dictionary) -> void:
	if not multiplayer.is_server():
		return
	_route(sender_id, action, data)


func _route(sender_id: int, action: String, data: Dictionary) -> void:
	action_received.emit(sender_id, action, data)
