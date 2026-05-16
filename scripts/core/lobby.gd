class_name Lobby
extends Control

@onready var _host_btn = $VBoxContainer/HBoxContainer2/HBoxContainer/Host
@onready var _scan_btn = $VBoxContainer/HBoxContainer2/HBoxContainer/Scan
@onready var _connect_btn = $VBoxContainer/HBoxContainer2/HBoxContainer/Connect
@onready var _disconnect_btn = $VBoxContainer/HBoxContainer2/HBoxContainer/Disconnect
@onready var _name_edit = $VBoxContainer/HBoxContainer/NameEdit
@onready var _host_edit = $VBoxContainer/HBoxContainer2/HostEdit
@onready var _server_list = $VBoxContainer/HBoxContainer3/VBoxContainer/ServerList
@onready var _lobby_list = $VBoxContainer/HBoxContainer3/VBoxContainer2/ItemList
@onready var _accept_dialog = $AcceptDialog
@onready var _start_btn = $VBoxContainer/HBoxContainer3/VBoxContainer2/HBoxContainer/start
@onready var _ready_btn = $VBoxContainer/HBoxContainer3/VBoxContainer2/HBoxContainer/ready
@onready var _add_bot_btn: Button
@onready var _remove_bot_btn: Button

var _bot_counter: int = 0


func _ready() -> void:
	_lobby_list.clear()
	_accept_dialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_accept_dialog.get_label().vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	if OS.has_environment("USERNAME"):
		_name_edit.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).replace("\\", "/").split("/")
		_name_edit.text = desktop_path[desktop_path.size() - 2]

	Conn.connected.connect(_on_connected)
	Conn.disconnected.connect(_on_disconnected)
	Conn.server_disconnected.connect(_on_server_disconnected)

	_build_bot_buttons()


func _build_bot_buttons() -> void:
	var hbox = $VBoxContainer/HBoxContainer3/VBoxContainer2/HBoxContainer

	_add_bot_btn = Button.new()
	_add_bot_btn.text = "+Bot"
	_add_bot_btn.visible = false
	_add_bot_btn.pressed.connect(_on_add_bot_pressed)
	hbox.add_child(_add_bot_btn)

	_remove_bot_btn = Button.new()
	_remove_bot_btn.text = "-Bot"
	_remove_bot_btn.visible = false
	_remove_bot_btn.pressed.connect(_on_remove_bot_pressed)
	hbox.add_child(_remove_bot_btn)


# ─── RPCs ────────────────────────────────────────────────

@rpc("any_peer", "call_local", "reliable")
func _announce_name(name: String) -> void:
	if not multiplayer.is_server():
		return
	var id = multiplayer.get_remote_sender_id()
	Players.update_player(id, {"name": name})
	_sync_players.rpc(Players.players)  # broadcast pra todos


@rpc("authority", "call_local", "reliable")
func _sync_players(player_list: Dictionary) -> void:
	Players.players = player_list
	_update_ui()


@rpc("any_peer", "call_local", "reliable")
func _toggle_ready() -> void:
	if not multiplayer.is_server():
		return
	var id = multiplayer.get_remote_sender_id()
	var state = Players.get_player(id).get("state", 0)
	Players.update_player(id, {"state": 0 if state == 1 else 1})
	_sync_players.rpc(Players.players)


@rpc("call_local")
func _start_match() -> void:
	var game = preload("res://scenes/game.tscn").instantiate()
	get_tree().root.add_child(game)
	get_parent().hide()


# ─── Conexão ─────────────────────────────────────────────


func _on_connected(peer_id: int) -> void:
	if multiplayer.is_server():
		_add_player_to_all(peer_id)
	else:
		Players.add_player(multiplayer.get_unique_id(), {"name": _name_edit.text, "state": 0})
		# Pede pro servidor sincronizar a lista completa
		_announce_name.rpc_id(1, _name_edit.text)
	_update_ui()


@rpc("any_peer")
func _fetch_players() -> void:
	_sync_players.rpc(Players.players)


func _on_disconnected(peer_id: int) -> void:
	if multiplayer.is_server():
		Players.remove_player(peer_id)
		_sync_players.rpc(Players.players)
	_update_ui()


func _on_server_disconnected() -> void:
	Players.clear()
	_stop_server()
	warning_dialog("Servidor desconectou")
	_update_ui()


func _add_player_to_all(new_peer: int) -> void:
	for id in Players.get_player_ids():
		_sync_players.rpc_id(new_peer, Players.players)
	Players.add_player(new_peer, {"name": "", "state": 0})
	_sync_players.rpc(Players.players)


# ─── UI ──────────────────────────────────────────────────


func _update_ui() -> void:
	_lobby_list.clear()
	for player in Players.get_all_players().values():
		var icon: Texture2D
		var label = player.get("name", "Player %d" % player.id)
		if player.get("is_bot", false):
			icon = preload("res://assets/ready.svg")
			label += " (Bot)"
		elif player.id == 1:
			icon = preload("res://assets/onwer.svg")
		elif player.state == 1:
			icon = preload("res://assets/ready.svg")
		else:
			icon = preload("res://assets/not_ready.svg")
		_lobby_list.add_item(label, icon, false)

	# Atualiza botão start
	_start_btn.disabled = true
	if Conn.is_host:
		for p in Players.get_all_players().values():
			if p.get("is_bot", false):
				continue
			if p.id != 1 and p.state != 1:
				return
		_start_btn.disabled = false


func _start_server() -> void:
	_scan_btn.disabled = true
	_host_btn.disabled = true
	_connect_btn.visible = false
	_disconnect_btn.visible = true
	_start_btn.visible = Conn.is_host
	_ready_btn.visible = not Conn.is_host
	_add_bot_btn.visible = Conn.is_host
	_remove_bot_btn.visible = Conn.is_host


func _stop_server() -> void:
	_scan_btn.disabled = false
	_host_btn.disabled = false
	_connect_btn.visible = true
	_disconnect_btn.visible = false
	_start_btn.visible = false
	_ready_btn.visible = false
	_add_bot_btn.visible = false
	_remove_bot_btn.visible = false
	_bot_counter = 0


func warning_dialog(message: String) -> void:
	_accept_dialog.dialog_text = message


# ─── Buttons ─────────────────────────────────────────────


func _on_scan_pressed() -> void:
	_server_list.clear()
	$UDPDiscovery.scan()


func _on_host_pressed() -> void:
	Conn.host()
	_start_server()
	Players.add_player(1, {"id": 1, "name": _name_edit.text, "state": 0})
	_update_ui()


func on_connect_server_list_pressed(ip: String) -> void:
	Conn.join(ip)
	_start_server()


func _on_connect_pressed() -> void:
	Conn.join(_host_edit.text)
	_start_server()


func _on_disconnect_pressed() -> void:
	Conn.leave()
	_stop_server()
	Players.clear()
	_update_ui()


func _on_ready_pressed() -> void:
	_toggle_ready.rpc()


func _on_start_pressed() -> void:
	if not multiplayer.is_server():
		return
	_start_match.rpc()


func _on_add_bot_pressed() -> void:
	if not multiplayer.is_server():
		return
	_bot_counter += 1
	var bot_id = -_bot_counter
	var bot_name = "Bot %d" % _bot_counter
	Players.add_player(
		bot_id,
		{"id": bot_id, "name": bot_name, "state": PlayerRegistry.PlayerState.READY, "is_bot": true}
	)
	_sync_players.rpc(Players.players)
	_update_ui()


func _on_remove_bot_pressed() -> void:
	if not multiplayer.is_server():
		return
	for pid in Players.get_player_ids():
		if pid < 0:
			Players.remove_player(pid)
			_sync_players.rpc(Players.players)
			_update_ui()
			return


func get_name_edit() -> Control:
	return _name_edit


func get_server_list() -> Control:
	return _server_list


func _on_back_pressed() -> void:
	var node = get_node("../MainMenu")
	if node:
		await node.on_multiplayer_back_pressed(self)
		queue_free()
