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
var _sync_timers: Dictionary = {}
var _sync_retries: Dictionary = {}
var _sync_timeout: float = 5.0
var _max_sync_retries: int = 3


func _init() -> void:
	peer.supported_protocols = ["ludus"]


func _ready() -> void:
	udp_listener.bind(LISTEN_PORT)

	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.server_disconnected.connect(_server_closed)
	multiplayer.connection_failed.connect(_failed_connection)
	multiplayer.connected_to_server.connect(_connected)


func _process(delta: float) -> void:
	_check_sync_timeouts(delta)

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
	var ips = filter_ipv4(IP.get_local_addresses())
	for ip in ips:
		var broadcast_ip = ip.split(".")
		broadcast_ip[3] = "255"
		print(".".join(broadcast_ip))
		print("Procurando servidores na LAN...")
		udp_sender.set_dest_address(".".join(broadcast_ip), LISTEN_PORT)
		udp_sender.put_var({"type": "server_discover"})


func is_ipv4(address: String) -> bool:
	var ipv4_regex = RegEx.new()
	ipv4_regex.compile(r"^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$")

	if ipv4_regex.search(address):
		# Extra validation: ensure each octet is <= 255
		var parts = address.split(".")
		for part in parts:
			var num = int(part)
			if num < 0 or num > 255:
				return false
		return true
	return false


func filter_ipv4(addresses: Array) -> Array:
	var result = []
	for addr in addresses:
		if is_ipv4(addr):
			result.append(addr)
	return result


# Sync System


func _check_sync_timeouts(delta: float) -> void:
	if players.size() <= 1:
		return

	var expired_syncs: Array = []

	for sync_id in _sync_timers.keys():
		_sync_timers[sync_id] += delta

		if _sync_timers[sync_id] >= _sync_timeout:
			expired_syncs.append(sync_id)

	for sync_id in expired_syncs:
		_handle_sync_timeout(sync_id)


func _handle_sync_timeout(sync_id: String) -> void:
	print("TIMEOUT: sync %s expirou" % sync_id)

	if not _sync_retries.has(sync_id):
		_sync_retries[sync_id] = 0

	_sync_retries[sync_id] += 1

	if _sync_retries[sync_id] <= _max_sync_retries:
		print("RETRY %d/%d para sync %s" % [_sync_retries[sync_id], _max_sync_retries, sync_id])
		_request_sync_retry(sync_id)
	else:
		print("FALHA: max retries atingido para sync %s" % sync_id)
		_fail_sync(sync_id)


func _request_sync_retry(sync_id: String) -> void:
	_sync_timers[sync_id] = 0
	_pending_sync[sync_id] = []
	rpc("_request_state_retry", sync_id)


@rpc("any_peer")
func _request_state_retry(sync_id: String) -> void:
	if players.size() <= 1:
		return
	print("Retry request para sync %s" % sync_id)
	if multiplayer.is_server():
		return
	rpc_id(1, "_confirm_state", sync_id, multiplayer.get_unique_id())


func _fail_sync(sync_id: String) -> void:
	print("FALHA: sync %s falhou apos %d retries" % [sync_id, _max_sync_retries])
	_clear_sync_data(sync_id)


func _clear_sync_data(sync_id: String) -> void:
	_pending_sync.erase(sync_id)
	_sync_timers.erase(sync_id)
	_sync_retries.erase(sync_id)


func _get_expected_confirmations() -> int:
	if players.size() <= 1:
		return 0
	return players.size()


func _is_sync_complete(sync_id: String) -> bool:
	return _pending_sync[sync_id].size() >= _get_expected_confirmations()


func _complete_sync(sync_id: String) -> void:
	#print("Sync %s completo!" % sync_id)
	_clear_sync_data(sync_id)
	sync_confirmed.emit(sync_id)
	#print("sync confirmado %s" % sync_id)


@rpc("any_peer","call_local")
func _confirm_state(sync_id: String, client_id: int) -> void:
	if players.size() <= 1:
		return

	if not _pending_sync.has(sync_id):
		print("WARNING: sync_id %s nao encontrado" % sync_id)
		return

	if _pending_sync[sync_id].has(client_id):
		print("WARNING: cliente %d ja confirmou sync %s" % [client_id, sync_id])
		return

	_pending_sync[sync_id].append(client_id)

	var expected = _get_expected_confirmations()
	#print("Sync %s: %d/%d confirmacoes" % [sync_id, _pending_sync[sync_id].size(), expected])

	if _is_sync_complete(sync_id):
		_complete_sync(sync_id)


func start_sync_tracking(sync_id: String) -> void:
	if not _pending_sync.has(sync_id):
		_pending_sync[sync_id] = []
	_sync_timers[sync_id] = 0
	_sync_retries[sync_id] = 0

	if players.size() <= 1:
		await get_tree().process_frame
		#print("Single-player: sync %s completo imediatamente" % sync_id)
		_complete_sync(sync_id)


# Trigger Action Queue


func enqueue_trigger_action(action: TriggerSystem.TriggerAction) -> void:
	_trigger_action_queue.append(action)

func modify_front_trigger_action(args) -> void:
	_trigger_action_queue[_trigger_action_queue.size()-1].args = args

func has_trigger_actions() -> bool:
	return not _trigger_action_queue.is_empty()


func get_next_trigger_action() -> TriggerSystem.TriggerAction:
	if _trigger_action_queue.is_empty():
		return null
	return _trigger_action_queue.pop_back()


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
	target: int, where: NetworkManager.ActionWhere, action: GameManager.Actions, ..._args
) -> void:
	if NetworkManager.multiplayer.is_server():
		NetworkManager.request_action(1,target,where, action, _args)
		return
	NetworkManager.request_action.rpc_id(1,multiplayer.get_unique_id(), target, where, action, _args)


## request the server to do certain actions
@rpc("any_peer","call_local")
func request_action(sender: int, target: int, where: int, action: int, _args = []) -> void:
	if not multiplayer.is_server():
		return
	match where:
		ActionWhere.LOBBY:
			lobby.do_action(sender, target, action, _args)
		ActionWhere.GAME:
			game.do_action(sender, target, action, _args)
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
