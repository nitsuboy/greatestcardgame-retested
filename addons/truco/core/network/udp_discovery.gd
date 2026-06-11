## LAN server discovery via UDP broadcast + active probe.
##
## Servers announce their presence at regular intervals (broadcast).
## Clients can actively probe by sending a discovery request;
## servers respond via unicast, enabling cross-platform discovery.
class_name UDPDiscovery
extends Node

## Emitted when a server is found during scan.
signal server_found(ip: String, name: String, players: String)

const PORT: int = 63574
const BROADCAST_INTERVAL: float = 2.0
const SCAN_DURATION: float = 3.0

var _server_peer: PacketPeerUDP
var _client_peer: PacketPeerUDP
var _server_name: String
var _scan_timer: float = 0.0
var _broadcast_timer: float = 0.0
var _scanning: bool = false
var _broadcasting: bool = false
var _known_servers: Dictionary = {}
var _discovery_sent: bool = false


## Starts broadcasting as a server with the given name.
## Also binds the port so it can respond to discovery probes.
func start_server(server_name: String) -> void:
	stop()
	_server_name = server_name
	_server_peer = PacketPeerUDP.new()
	_server_peer.set_broadcast_enabled(true)
	_server_peer.bind(PORT)
	_broadcasting = true
	_broadcast_timer = 0.0
	set_process(true)


## Stops server broadcasting.
func stop_server() -> void:
	_broadcasting = false
	if _server_peer:
		_server_peer.close()
		_server_peer = null


## Starts scanning for servers on the local network.
## Sends a discovery probe so servers respond via unicast.
func scan() -> void:
	stop()
	_client_peer = PacketPeerUDP.new()
	var err = _client_peer.bind(PORT, "*")
	if err != OK:
		push_warning("UDPDiscovery: failed to bind port %d: %d" % [PORT, err])
		_client_peer = null
		return
	_client_peer.set_broadcast_enabled(true)
	# Send active discovery probe
	var msg = "CARDWORK_DISCOVER"
	_client_peer.set_dest_address("255.255.255.255", PORT)
	_client_peer.put_packet(msg.to_utf8_buffer())
	_discovery_sent = true
	_scanning = true
	_scan_timer = 0.0
	_known_servers.clear()
	set_process(true)


## Stops all scan/broadcast and frees resources.
func stop() -> void:
	_scanning = false
	_broadcasting = false
	if _client_peer:
		_client_peer.close()
		_client_peer = null
	stop_server()
	_discovery_sent = false
	set_process(false)


func _process(delta: float) -> void:
	if _broadcasting:
		_broadcast(delta)
	if _scanning:
		_receive()
		_scan_timer += delta
		if _scan_timer >= SCAN_DURATION:
			stop()


func _broadcast(delta: float) -> void:
	# Respond to incoming discovery probes (active discovery)
	while _server_peer.get_available_packet_count() > 0:
		var packet = _server_peer.get_packet()
		var ip = _server_peer.get_packet_ip()
		var text = packet.get_string_from_utf8()
		if text == "CARDWORK_DISCOVER":
			var msg = "CARDWORK|%s|%d|%d" % [_server_name, Players.connected_count(), Players.MAX_PLAYERS]
			_server_peer.set_dest_address(ip, PORT)
			_server_peer.put_packet(msg.to_utf8_buffer())

	# Periodic broadcast announcement (passive discovery)
	_broadcast_timer += delta
	if _broadcast_timer < BROADCAST_INTERVAL:
		return
	_broadcast_timer = 0.0

	var players = Players.connected_count()
	var msg = "CARDWORK|%s|%d|%d" % [_server_name, players, Players.MAX_PLAYERS]
	var bytes = msg.to_utf8_buffer()
	_server_peer.set_dest_address("255.255.255.255", PORT)
	_server_peer.put_packet(bytes)


func _receive() -> void:
	while _client_peer.get_available_packet_count() > 0:
		var packet = _client_peer.get_packet()
		var ip = _client_peer.get_packet_ip()
		var text = packet.get_string_from_utf8()
		var parts = text.split("|")
		if parts.size() >= 4 and parts[0] == "CARDWORK":
			var data = { "name": parts[1], "players": "%s/%s" % [parts[2], parts[3]] }
			if _known_servers.get(ip) != data:
				_known_servers[ip] = data
				server_found.emit(ip, data.name, data.players)
