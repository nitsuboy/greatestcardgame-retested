class_name TurnManager
extends RefCounted

var turn: int = -1
var player_turn: int = -1
var direction: bool = true


func next_turn(ids: Array[int], amount: int = 1, should_change: bool = true) -> int:
	var idx = ids.find(player_turn)
	if direction:
		player_turn = ids[(idx + amount) % ids.size()]
	else:
		player_turn = ids[(idx + amount + ids.size()) % ids.size()]
	if should_change:
		turn += 1
	return player_turn


func search_player(ids: Array[int], offset: int) -> int:
	var idx = ids.find(player_turn)
	return ids[(idx + offset) % ids.size()]


func set_player_turn(new_player: int) -> void:
	player_turn = new_player


func reset() -> void:
	turn = -1
	player_turn = -1
	direction = true
