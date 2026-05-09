class_name SyncBarrier
extends Node

signal sync_confirmed(sync_id: String)
signal sync_failed(sync_id: String)
signal peer_desynced(peer_id: int)

@export var timeout: float = 5.0
@export var max_retries: int = 3

var player_registry: PlayerRegistry

var _current_sync_id: String = ""
var _pending: Array[int] = []
var _timer: float = 0.0
var _retries: int = 0
var _active: bool = false


func start(sync_id: String) -> void:
	if player_registry.connected_count() <= 1:
		sync_confirmed.emit(sync_id)
		return
	_current_sync_id = sync_id
	_pending = []
	_timer = 0.0
	_retries = 0
	_active = true


func _do_confirm(sync_id: String, peer_id: int) -> void:
	if not _active or _current_sync_id != sync_id:
		return
	if peer_id in _pending:
		return
	_pending.append(peer_id)
	if _pending.size() >= player_registry.connected_count():
		_complete()


func _complete() -> void:
	_active = false
	sync_confirmed.emit(_current_sync_id)


func _process(delta: float) -> void:
	if not _active:
		return
	_timer += delta
	if _timer < timeout:
		return

	_retries += 1
	if _retries <= max_retries:
		_timer = 0.0
		_pending = []
		_request_retry.rpc(_current_sync_id)
		return

	_active = false
	for pid in player_registry.get_player_ids():
		if pid not in _pending:
			peer_desynced.emit(pid)
	sync_failed.emit(_current_sync_id)


@rpc("any_peer", "call_local", "reliable")
func _rpc_confirm(sync_id: String, peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	_do_confirm(sync_id, peer_id)


@rpc("any_peer", "call_local", "reliable")
func _request_retry(sync_id: String) -> void:
	if not multiplayer.is_server():
		_rpc_confirm.rpc_id(1, sync_id, multiplayer.get_unique_id())
