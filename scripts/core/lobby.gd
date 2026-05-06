class_name Lobby
extends Control

enum Actions { UPDATE_STATE, START_MATCH }

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


func _init() -> void:
	Net.lobby = self


func _ready() -> void:
	_lobby_list.clear()

	_accept_dialog.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_accept_dialog.get_label().vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	if OS.has_environment("USERNAME"):
		_name_edit.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).replace("\\", "/").split("/")
		_name_edit.text = desktop_path[desktop_path.size() - 2]


# RPC

@rpc("call_local")
func add_player(id, player_data) -> void:
	Players.add_player(id, player_data)
	refresh_lobby_list()


@rpc("call_local")
func del_player(id) -> void:
	Players.remove_player(id)
	refresh_lobby_list()


@rpc("any_peer")
func set_player_data(data) -> void:
	if not multiplayer.is_server():
		return
	var sender = multiplayer.get_remote_sender_id()
	update_player_data.rpc(sender, data)


@rpc("call_local")
func update_player_data(player, data) -> void:
	Players.update_player(player, data)
	refresh_lobby_list()


@rpc("call_local")
func _start_match() -> void:
	var game = Globals.game.instantiate()
	get_tree().root.add_child(game)


# UI


func _start_server() -> void:
	_scan_btn.disabled = true
	_host_btn.disabled = true
	_connect_btn.visible = false
	_disconnect_btn.visible = true
	if Net.is_host:
		_start_btn.visible = true
	else:
		_ready_btn.visible = true


func _stop_server() -> void:
	_scan_btn.disabled = false
	_host_btn.disabled = false
	_connect_btn.visible = true
	_disconnect_btn.visible = false
	_start_btn.visible = false
	_ready_btn.visible = false


func _refresh_start_btn() -> void:
	var can_start: bool = true
	for p in Players.get_all_players().values():
		if p["id"] == 1:
			continue
		if p["state"] == 0:
			can_start = false
			break
	_start_btn.disabled = not can_start


func warning_dialog(message: String) -> void:
	_accept_dialog.dialog_text = message


# Misc


func do_action(sender: int, _target: int, _action: int, _args) -> void:
	if not multiplayer.is_server():
		return
	match _action:
		Actions.UPDATE_STATE:
			if Players.get_player(sender)["state"] == 1:
				update_player_data.rpc(sender, {"state": 0})
			else:
				update_player_data.rpc(sender, {"state": 1})
			_refresh_start_btn()
		Actions.START_MATCH:
			_start_match.rpc()
			_refresh_start_btn()
		_:
			push_warning("unknow action")


func refresh_lobby_list() -> void:
	_lobby_list.clear()
	for player in Players.get_all_players().values():
		if player["id"] == 1:
			_lobby_list.add_item(player["name"], preload("res://assets/onwer.svg"), false)
			continue
		var icon: Texture2D
		match player["state"]:
			1:
				icon = preload("res://assets/ready.svg")
			_:
				icon = preload("res://assets/not_ready.svg")
		_lobby_list.add_item(player["name"], icon, false)


# Connection


func on_peer_add(id: int) -> void:
	if not multiplayer.is_server():
		return
	for existing_id in Players.get_player_ids():
		var existing_player = Players.get_player(existing_id)
		add_player.rpc_id(id, existing_id, existing_player)
	add_player.rpc(id, {"name": ""})
	_refresh_start_btn()


func on_peer_del(id: int) -> void:
	if not multiplayer.is_server():
		return
	del_player.rpc(id)
	_refresh_start_btn()


# Buttons


func _on_scan_pressed() -> void:
	_server_list.clear()
	Net.scan_servers()


func _on_host_pressed() -> void:
	Net.host_server()
	_start_server()
	add_player(1, {"name": _name_edit.text})


func on_connect_server_list_pressed(ip: String) -> void:
	Net.connect_to_server(ip)
	_start_server()


func _on_connect_pressed() -> void:
	Net.connect_to_server(_host_edit.text)
	_start_server()


func _on_disconnect_pressed() -> void:
	Net.close_network()
	_stop_server()
	refresh_lobby_list()


func _on_ready_pressed() -> void:
	Net.client_request_action(multiplayer.get_unique_id(), Net.ActionWhere.LOBBY, 0)


func _on_start_pressed() -> void:
	if not multiplayer.is_server():
		return
	do_action(1, 1, 1, 0)


## Getters publicos (para API)
func get_name_edit() -> Control:
	return _name_edit


func get_server_list() -> Control:
	return _server_list
