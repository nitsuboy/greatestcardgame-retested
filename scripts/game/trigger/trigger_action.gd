class_name TriggerAction
extends RefCounted

var action_type: GameManager.Actions
var args: Array
var player_id: int
var target_id: int


func _init(target: int, type: GameManager.Actions, _args: Array = [], player: int = 1) -> void:
	action_type = type
	args = _args
	target_id = target
	player_id = player
