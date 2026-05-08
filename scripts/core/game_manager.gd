@abstract class_name GameManager
extends Node

enum GameState { SETUP, TURN_START, PROCESS_TURN, END_GAME }

enum Actions {
	PLAY_CARD,
	END_TURN,
	DRAW_CARD,
	DRAW_CARD_UNSK,
	DISCARD_CARD,
	MODIFY_CARD,
	CREATE_CARD,
	SKIP_TURN,
	START_TURN,
	SPAWN_PROTOTYPE,
	CHANGE_COLOR
}

@export var _dealer: Dealer
@export var _rules: Rules
var _turn_manager := TurnManager.new()
var _hands := HandsController.new()
var _players_entities: Dictionary[int, Entity] = {}
var _state_track: int = 0

@abstract func get_dealer() -> Dealer


## do certain action, only host can perform this function
func do_action(_sender: int, _target: int, _action: int, _args) -> void:
	if not multiplayer.is_server():
		return
	print("==============================")
	print("  Sender: %d | Action: %s" % [_sender, GameManager.Actions.keys()[_action]])
	print("  Args: %s" % [str(_args)])
	var vlc = ValidationContext.new()
	vlc.action = _action
	vlc.player_id = _sender
	vlc.target_id = _target
	vlc.args = _args
	var result: ValidationResult = _rules.validate(vlc)
	if result.is_valid:
		await _dispatch_action(_sender, _target, _action, _args, result)
	else:
		print(result.rejected_reason)
	_process_trigger_queue()


@abstract func _dispatch_action(
	_sender: int, _target: int, _action: int, _args, result: ValidationResult
) -> void


func _process_trigger_queue() -> void:
	if TriggerRegistry.has_trigger_actions():
		var action = TriggerRegistry.get_next_trigger_action()
		Net.request_action(
			action.player_id,
			action.target_id,
			Net.ActionWhere.GAME,
			action.action_type,
			action.args
		)
