class_name SimpleGameManager
extends Node

signal game_started
signal turn_started(player_id)
signal turn_ended(player_id)
signal game_ended(winner_id)

enum GameState { SETUP, TURN_START, PROCESS_TURN, END_GAME }
enum Actions { ROLL }

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
	if action not in ACTIONS:
		_log.rpc("Invalid action: %s" % action)
		return

	do_action(action)
	next_turn()


# State machine


func change_state(new_state: GameState) -> void:
	state = new_state
	match state:
		GameState.SETUP:
			_setup_game()
		GameState.TURN_START:
			_start_turn()
		GameState.PROCESS_TURN:
			pass
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


func _setup_game():
	_turn = 0
	for player in _players:
		_setup_player(player)
	set_turn.rpc(0)
	emit_signal("game_started")
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
	var player = _players[_player_turn]
	emit_signal("turn_started", player.id)


func _end_turn():
	var player = players[current_player_index]
	emit_signal("turn_ended", player.id)

	current_player_index = (current_player_index + 1) % players.size()
	current_turn += 1

	_check_game_end()

	_start_turn()


#


func _play_card(card, zone):
	var p = card.global_position
	#var parent = card.get_parent()
	parent.remove_child(card)
	zone.static_container.add_child(card)
	card.global_position = p
	card.rotation = 0


func _process_ai_turn(player: Player):
	await get_tree().create_timer(0.5).timeout

	# Exemplo simples: joga a primeira carta
	if player.hand.get_child_count() > 0:
		_play_card(player, player.hand.get_card(0), _game_stack)

	await get_tree().create_timer(0.5).timeout
	end_turn()


func _check_game_end():
	pass
