## LAN server discovery via UDP broadcast.
##
## Servers announce their presence at regular intervals.
## Clients scan the network and receive a list of servers.
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


## Starts broadcasting as a server with the given name.
func start_server(server_name: String) -> void:
	stop()
	_server_name = server_name
	_server_peer = PacketPeerUDP.new()
	_server_peer.set_broadcast_enabled(true)
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
func scan() -> void:
	stop()
	_client_peer = PacketPeerUDP.new()
	var err = _client_peer.bind(PORT, "*")
	if err != OK:
		push_warning("UDPDiscovery: failed to bind port %d: %d" % [PORT, err])
		_client_peer = null
		return
	_scanning = true
	_scan_timer = 0.0
	set_process(true)


## Stops all scan/broadcast and frees resources.
func stop() -> void:
	_scanning = false
	_broadcasting = false
	if _client_peer:
		_client_peer.close()
		_client_peer = null
	stop_server()
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
	_broadcast_timer += delta
	if _broadcast_timer < BROADCAST_INTERVAL:
		return
	_broadcast_timer = 0.0

	var players = Players.connected_count()
	var msg = "CARDWORK|%s|%d|8" % [_server_name, players]
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
			server_found.emit(ip, parts[1], "%s/%s" % [parts[2], parts[3]])
