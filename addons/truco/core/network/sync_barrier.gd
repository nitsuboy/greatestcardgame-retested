class_name SyncBarrier
extends Node

signal sync_confirmed(sync_id: String)
signal sync_failed(sync_id: String)
signal peer_desynced(peer_id: int)

@export var timeout: float = 5.0
@export var max_retries: int = 3

var _pending_syncs: Dictionary = {}  # sync_id → SyncEntry


func start(sync_id: String) -> void:
	if Players.connected_count() <= 1:
		sync_confirmed.emit(sync_id)
		return
	if _pending_syncs.has(sync_id):
		return  # já existe, ignora duplicata
	_pending_syncs[sync_id] = {"pending": [], "timer": 0.0, "retries": 0}


func clear() -> void:
	_pending_syncs.clear()


func _do_confirm(sync_id: String, peer_id: int) -> void:
	var entry = _pending_syncs.get(sync_id)
	if not entry:
		return  # sync desconhecido ou já resolvido
	if peer_id in entry.pending:
		return  # já confirmou
	entry.pending.append(peer_id)
	if entry.pending.size() >= Players.connected_count():
		_complete(sync_id)


func _complete(sync_id: String) -> void:
	_pending_syncs.erase(sync_id)
	sync_confirmed.emit(sync_id)


func _process(delta: float) -> void:
	var timed_out: Array[String] = []
	for sync_id in _pending_syncs:
		var entry = _pending_syncs[sync_id]
		entry.timer += delta
		if entry.timer < timeout:
			continue
		# Timeout para esta sync
		entry.retries += 1
		if entry.retries <= max_retries:
			entry.timer = 0.0
			entry.pending = []
			_request_retry.rpc(sync_id)
			continue
		# Esgotou retries → falha permanente
		for pid in Players.get_player_ids():
			if pid not in entry.pending:
				peer_desynced.emit(pid)
		sync_failed.emit(sync_id)
		timed_out.append(sync_id)
	for sync_id in timed_out:
		_pending_syncs.erase(sync_id)


@rpc("any_peer", "call_local", "reliable")
func _rpc_confirm(sync_id: String, peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	_do_confirm(sync_id, peer_id)


@rpc("any_peer", "call_local", "reliable")
func _request_retry(sync_id: String) -> void:
	if not multiplayer.is_server():
		_rpc_confirm.rpc_id(1, sync_id, multiplayer.get_unique_id())
