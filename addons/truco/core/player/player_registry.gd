class_name PlayerRegistry
extends Node

signal player_added(id: int, data: Dictionary)
signal player_removed(id: int)
signal player_updated(id: int, fields: Dictionary)

enum PlayerState { NOT_READY, READY, PLAYING }

var players: Dictionary[int, Dictionary] = {}


func add_player(id: int, player_data: Dictionary) -> void:
	if not player_data.has("id"):
		player_data["id"] = id
	if not player_data.has("state"):
		player_data["state"] = PlayerState.NOT_READY
	players[id] = player_data
	player_added.emit(id, player_data)


func remove_player(id: int) -> void:
	if players.has(id):
		players.erase(id)
		player_removed.emit(id)


func update_player(id: int, fields: Dictionary) -> void:
	if players.has(id):
		for key in fields.keys():
			var value = fields[key]
			if value != null and not (typeof(value) == TYPE_STRING and value.strip_edges() == ""):
				players[id][key] = value
		player_updated.emit(id, fields)


func get_player(id: int) -> Dictionary:
	return players.get(id, {})


func has_player(id: int) -> bool:
	return players.has(id)


func get_all_players() -> Dictionary:
	return players


func get_player_ids() -> Array[int]:
	return players.keys()


func connected_count() -> int:
	return players.size()


func clear() -> void:
	players.clear()
