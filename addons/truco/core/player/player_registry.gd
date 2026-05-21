## Central registry of connected players.
##
## Holds a dictionary of players keyed by peer_id.
## Manages states (NOT_READY, READY, PLAYING).
## Registered as global autoload (Players).
class_name PlayerRegistry
extends Node

## Emitted when a player is added.
signal player_added(id: int, data: Dictionary)
## Emitted when a player is removed.
signal player_removed(id: int)
## Emitted when a player's data is updated.
signal player_updated(id: int, fields: Dictionary)

enum PlayerState { NOT_READY, READY, PLAYING }

## Player dictionary: peer_id → {id, name, state, ...}.
var players: Dictionary[int, Dictionary] = {}


## Adds a player to the registry.
func add_player(id: int, player_data: Dictionary) -> void:
	if not player_data.has("id"):
		player_data["id"] = id
	if not player_data.has("state"):
		player_data["state"] = PlayerState.NOT_READY
	players[id] = player_data
	player_added.emit(id, player_data)


## Removes a player from the registry.
func remove_player(id: int) -> void:
	if players.has(id):
		players.erase(id)
		player_removed.emit(id)


## Updates specific fields of a player.
func update_player(id: int, fields: Dictionary) -> void:
	if players.has(id):
		for key in fields.keys():
			var value = fields[key]
			if value != null and not (typeof(value) == TYPE_STRING and value.strip_edges() == ""):
				players[id][key] = value
		player_updated.emit(id, fields)


## Returns a player's data by peer_id.
func get_player(id: int) -> Dictionary:
	return players.get(id, {})


## Checks if a player exists in the registry.
func has_player(id: int) -> bool:
	return players.has(id)


## Returns all players.
func get_all_players() -> Dictionary:
	return players


## Returns a list of all player peer_ids.
func get_player_ids() -> Array[int]:
	return players.keys()


## Number of connected players.
func connected_count() -> int:
	return players.size()


## Clears all players from the registry.
func clear() -> void:
	players.clear()
