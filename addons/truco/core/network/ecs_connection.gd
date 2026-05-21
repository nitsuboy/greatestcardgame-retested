## Multiplayer connection management via WebSocket.
##
## Handles server creation and client connections.
## Uses WebSocketMultiplayerPeer as transport.
## Registered as global autoload (Conn).
class_name ECSConnection
extends Node

## Emitted when a peer connects (server) or connects to server (client).
signal connected(peer_id: int)
## Emitted when a peer disconnects.
signal disconnected(peer_id: int)
## Emitted when the server closes the connection.
signal server_disconnected
## Emitted when connection fails.
signal connection_failed

enum Role { NONE, SERVER, CLIENT }

const DEFAULT_PORT: int = 7357

## Current connection role (NONE, SERVER, CLIENT).
var role: Role = Role.NONE
## Whether this peer is the host.
var is_host: bool = false
## WebSocket peer for communication.
var peer: WebSocketMultiplayerPeer


func _init() -> void:
	peer = WebSocketMultiplayerPeer.new()


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)


## Starts a server on the specified port.
func host(port: int = DEFAULT_PORT) -> void:
	leave()
	role = Role.SERVER
	is_host = true
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer


## Connects to a server at the given address and port.
func join(address: String, port: int = DEFAULT_PORT) -> void:
	leave()
	role = Role.CLIENT
	is_host = false
	peer.create_client("ws://%s:%d" % [address, port])
	multiplayer.multiplayer_peer = peer


## Disconnects and clears connection state.
func leave() -> void:
	role = Role.NONE
	is_host = false
	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		peer.close()
	multiplayer.multiplayer_peer = null


func _on_peer_connected(id: int) -> void:
	connected.emit(id)


func _on_peer_disconnected(id: int) -> void:
	disconnected.emit(id)


func _on_server_disconnected() -> void:
	role = Role.NONE
	is_host = false
	server_disconnected.emit()


func _on_connection_failed() -> void:
	role = Role.NONE
	connection_failed.emit()


func _on_connected_to_server() -> void:
	connected.emit(multiplayer.get_unique_id())
