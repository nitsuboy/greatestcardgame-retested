extends Node

signal sync_confirmed(sync_id)

enum PlayerState { NOT_READY, READY, PLAYING }
enum ActionWhere { LOBBY, GAME }

const DEF_PORT = 7357
const SEND_PORT = 63575
const LISTEN_PORT = 63574
const PROTO_NAME = "ludus"

@export var lobby: Lobby
@export var game: GameManager

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var udp_sender: PacketPeerUDP = PacketPeerUDP.new()
var udp_listener: PacketPeerUDP = PacketPeerUDP.new()
var is_host: bool = false
var server_id: Array = []
var server_data: Array
var server_size: int = 4
var players: Dictionary = {}
var _pending_sync: Dictionary = {}
var _trigger_action_queue: Array[TriggerSystem.TriggerAction] = []


func _init() -> void:
	peer.supported_protocols = ["ludus"]


func _ready() -> void:
	udp_listener.bind(LISTEN_PORT)

	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.server_disconnected.connect(_server_closed)
	multiplayer.connection_failed.connect(_failed_connection)
	multiplayer.connected_to_server.connect(_connected)


func _process(_delta: float) -> void:
	if udp_listener.get_available_packet_count() > 0:
		var msg = udp_listener.get_var()
		var ip = udp_listener.get_packet_ip()
		match msg.get("type", ""):
			"server_discover":
				if is_host:
					udp_sender.set_dest_address(ip, LISTEN_PORT)
					udp_sender.put_var(
						{
							"type": "server_data",
							"players": str(players.size()),
							"server_size": str(server_size),
							"server_name": lobby._name_edit.text + " server",
							"identifier": OS.get_unique_id()
						}
					)
					print("Respondido discovery para ", ip)
			"server_data":
				if not server_id.has(msg.get("identifier", "")):
					server_id.append(msg.get("identifier", ""))
					server_data.append(msg)
					var server_item: ServerItem = lobby._server_list.add_item(
						msg.get("players", ""), msg.get("server_name", "")
					)
					server_item.connect_button.pressed.connect(
						lobby.on_connect_server_list_pressed.bind(ip)
					)
			_:
				print(msg)


func scan_servers() -> void:
	server_id.clear()
	server_data.clear()
	udp_sender.set_broadcast_enabled(true)
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.") or ip.begins_with("10.") or ip.begins_with("172."):
			var broadcast_ip = ip.split(".")
			broadcast_ip[3] = "255"
			print("Procurando servidores na LAN...")
			udp_sender.set_dest_address(".".join(broadcast_ip), LISTEN_PORT)
			udp_sender.put_var({"type": "server_discover"})


# Utils


## get all local adresses from all disponible networks
func get_lan_ip() -> String:
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.") or ip.begins_with("10.") or ip.begins_with("172."):
			return ip
	return "0.0.0.0"  # fallback


@rpc("any_peer")
func _receive_state(sync_id: String) -> void:
	if multiplayer.is_server():
		return
	rpc_id(1, "_confirm_state", sync_id, multiplayer.get_unique_id())


@rpc("any_peer")
func _confirm_state(sync_id: String, client_id: int) -> void:
	if not _pending_sync.has(sync_id):
		return
	_pending_sync[sync_id].append(client_id)
	if _pending_sync[sync_id].size() == NetworkManager.players.size() - 1:
		sync_confirmed.emit(sync_id)


# Trigger Action Queue

func enqueue_trigger_action(action: TriggerSystem.TriggerAction) -> void:
	_trigger_action_queue.append(action)


func has_trigger_actions() -> bool:
	return not _trigger_action_queue.is_empty()


func get_next_trigger_action() -> TriggerSystem.TriggerAction:
	if _trigger_action_queue.is_empty():
		return null
	return _trigger_action_queue.pop_front()


# Player data


func add_player(id: int, player_data: Dictionary) -> void:
	if not player_data.has("id"):
		player_data["id"] = id
	if not player_data.has("state"):
		player_data["state"] = PlayerState.NOT_READY
	players[id] = player_data


func del_player(id: int) -> void:
	if players.has(id):
		players.erase(id)


func update_player_data(id: int, fields: Dictionary) -> void:
	if players.has(id):
		for key in fields.keys():
			var value = fields[key]
			# Ignora valores nulos ou strings vazias
			if value != null and !(typeof(value) == TYPE_STRING and value.strip_edges() == ""):
				players[id][key] = value


# Multiplayer


func client_request_action(
	where: NetworkManager.ActionWhere, action: GameManager.Actions, ..._args
) -> void:
	if NetworkManager.multiplayer.is_server():
		NetworkManager.request_action(where, action, _args)
		return

	NetworkManager.request_action.rpc_id(1, where, action, _args)


## request the server to do certain actions
@rpc("any_peer")
func request_action(where: int, action: int, _args) -> void:
	if not is_multiplayer_authority():
		return
	var sender = multiplayer.get_remote_sender_id()
	match where:
		ActionWhere.LOBBY:
			lobby.do_action(sender, action, _args)
		ActionWhere.GAME:
			game.do_action(sender, action, _args)
		_:
			push_warning("unable to identify where to peform action")


# Connection


func _connect(adress) -> void:
	multiplayer.multiplayer_peer = null
	peer.create_client("ws://" + adress + ":" + str(DEF_PORT))
	multiplayer.multiplayer_peer = peer


func _host() -> void:
	is_host = true
	udp_sender.set_broadcast_enabled(false)

	multiplayer.multiplayer_peer = null
	peer.create_server(DEF_PORT)
	multiplayer.multiplayer_peer = peer


func _server_closed() -> void:
	print("server closed")
	multiplayer.multiplayer_peer = null
	players.clear()
	peer.close()
	if lobby:
		lobby.refresh_lobby_list()
		lobby.warning_dialog("Connection terminated")


func _close_network() -> void:
	if is_host:
		is_host = false
	print("connection closed")
	multiplayer.multiplayer_peer = null
	players.clear()
	peer.close()


func _failed_connection() -> void:
	print("faild connection")
	multiplayer.multiplayer_peer = null
	peer.close()


func _connected() -> void:
	if lobby:
		lobby.set_player_data.rpc({"name": lobby._name_edit.text})


func _peer_connected(id: int) -> void:
	if lobby:
		lobby.on_peer_add(id)


func _peer_disconnected(id: int) -> void:
	print("Disconnected %d" % id)
	if lobby:
		lobby.on_peer_del(id)
