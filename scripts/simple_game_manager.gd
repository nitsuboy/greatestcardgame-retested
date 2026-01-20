class_name SimpleGameManager
extends Node

signal game_started
signal turn_started(player_id)
signal turn_ended(player_id)
signal game_ended(winner_id)

enum GameState { SETUP, TURN_START, PROCESS_TURN, END_GAME }
enum Actions { PLAY }

@export var _dealer: SimpleDealer
@export var _initial_hand_size: int = 7
@export var _game_stack: PlayZone

var is_multiplayer: bool = false
var state: GameState = GameState.SETUP

var _players: Array = []  # Array de PlayerData
var _turn: int = -1
var _player_turn: int = -1


func _process(delta: float) -> void:
	if Globals.is_dragging:
		DragSystem.update(delta)


func _ready() -> void:
	_players.append($"../Node2D/Player")
	$"../Node2D/Player2".is_ai = true
	_players.append($"../Node2D/Player2")

	#_game_stack.connect("card_played", end_turn)
	change_state(GameState.SETUP)


# Debug

@rpc("call_local")
func _log(what):
	$HBoxContainer/VBoxContainer2/RichTextLabel.add_text(what + "\n")


# RPC

@rpc("any_peer")
func request_action(action):
	if not is_multiplayer_authority():
		return
	var sender = multiplayer.get_remote_sender_id()
	print(sender)
	print(_players)
	if _players[_turn] != sender:
		_log.rpc("Someone is trying to cheat! %s" % str(sender))
		return
	if action is not Actions:
		_log.rpc("Invalid action: %s" % action)
		return

	do_action(action)
	next_turn()


func do_action(action):
	var val = randi() % 100
	_log.rpc("%s: %ss %d" % [action, val])


# State machine


func change_state(new_state: GameState) -> void:
	state = new_state
	match state:
		GameState.SETUP:
			_start_game()
		GameState.TURN_START:
			_start_turn()
		GameState.PROCESS_TURN:
			_process_turn()
		GameState.END_GAME:
			pass


@rpc("call_local")
func set_turn(player_turn):
	_player_turn = player_turn
	if player_turn >= _players.size():
		return
	if _players[player_turn] != multiplayer.get_unique_id():
		_players[player_turn].hand.block_hand()
	else:
		_players[player_turn].hand.unblock_hand()


func _start_game():
	_setup_game()


func _setup_game():
	_turn = 0
	_player_turn = 0
	for player in _players:
		_setup_player(player)
	change_state(GameState.TURN_START)


func _setup_player(player: Player):
	for i in range(_initial_hand_size):
		var card: Card = _dealer.draw_card()
		if card:
			player.add_card_to_hand(card)
	player.hand.block_hand()


func next_turn():
	_turn += 1
	_player_turn += 1
	if _player_turn >= _players.size():
		_player_turn = 0
	set_turn.rpc(_player_turn)


func _start_turn():
	set_turn.rpc(_player_turn)


func _process_turn():
	_check_win()


func _check_win():
	change_state(GameState.TURN_START)


func _end_turn():
	change_state(GameState.PROCESS_TURN)


# Misc


func _play_card(card, zone):
	var p = card.global_position
	var parent = card.get_parent()
	parent.remove_child(card)
	zone.static_container.add_child(card)
	card.global_position = p
	card.rotation = 0


func _process_ai_turn(player: Player):
	await get_tree().create_timer(0.5).timeout
	# Exemplo simples: joga a primeira carta
	if player.hand.get_child_count() > 0:
		_play_card(player, _game_stack)
	await get_tree().create_timer(0.5).timeout
	_end_turn()
