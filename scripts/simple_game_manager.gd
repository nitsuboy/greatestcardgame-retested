class_name SimpleGameManager
extends Node

enum GameState { SETUP, TURN_START, PROCESS_TURN, END_GAME }
enum Actions { PLAY }

@export var _dealer: SimpleDealer
@export var _initial_hand_size: int = 7
@export var _game_stack: PlayZone
@export var _players_node: Node2D
@export var _player: PackedScene

var state: GameState = GameState.SETUP

var _turn: int = -1
var _player_turn: int = -1
var _players_nodes: Dictionary = {}
var _curve: Curve2D


func _process(delta: float) -> void:
	if Globals.is_dragging:
		DragSystem.update(delta)


func _ready() -> void:
	_curve = make_rounded_square(50.0, 150.0)
	change_state(GameState.SETUP)


# Debug

@rpc("call_local")
func _log(what):
	$HBoxContainer/VBoxContainer2/RichTextLabel.add_text(what + "\n")


# RPC

@rpc("call_local")
func set_turn(player_id: int):
	_player_turn = player_id
	for id in NetworkManager.players.keys():
		var player = _players_nodes[id]
		if id == multiplayer.get_unique_id():
			player.hand.unblock_hand()
		else:
			player.hand.block_hand()


## do certain action only server host can perform this function
func do_action(_sender: int, _action: int, ..._args) -> void:
	if not is_multiplayer_authority():
		return
	match action:
		0:
			_play_card(_args[0], _args[1])
		1:
			pass
		_:
			push_warning("unknow action")


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


func _start_game():
	_setup_game()


func _setup_game():
	_turn = 1
	_player_turn = 1
	var aux = 0
	for player in NetworkManager.players:
		var p: Node2D = _player.instantiate()
		var transform = get_point_on_path(_curve, aux / float(NetworkManager.players.size()))
		aux += 1
		_players_node.add_child(p)
		p.transform = transform
		p.scale = Vector2.ONE * .7
		p.rotate(PI)
		_players_nodes[player] = p

	for player in NetworkManager.players:
		_setup_player(_players_nodes[player])
	change_state(GameState.TURN_START)


func _setup_player(player: Player):
	for i in range(_initial_hand_size):
		var card: Card = _dealer.draw_card()
		if card:
			player.add_card_to_hand(card)
	player.hand.block_hand()


func next_turn():
	var ids = NetworkManager.players.keys()
	var idx = ids.find(_player_turn)
	_player_turn = ids[(idx + 1) % ids.size()]
	set_turn.rpc(_player_turn)


func _start_turn():
	if not is_multiplayer_authority():
		return
	set_turn.rpc(_player_turn)


func _process_turn():
	_check_win()


func _check_win():
	change_state(GameState.TURN_START)


func _end_turn():
	change_state(GameState.PROCESS_TURN)


# Misc


func get_point_on_path(curve: Curve2D, t: float) -> Transform2D:
	# garante que t esteja entre 0 e 1
	t = clamp(t, 0.0, 1.0)
	var length = curve.get_baked_length()
	var distance = t * length
	return curve.sample_baked_with_rotation(distance)


func make_rounded_square(corner_radius: float = 50.0, margin: float = 50.0) -> Curve2D:
	var screen_size = get_viewport().get_visible_rect().size
	var w = screen_size.x
	var h = screen_size.y
	var curve = Curve2D.new()

	curve.add_point(Vector2(w / 2, h - margin))
	# canto inferior esquerdo
	curve.add_point(Vector2(margin + corner_radius, h - margin))
	curve.add_point(Vector2(margin, h - margin - corner_radius))
	# canto superior esquerdo
	curve.add_point(Vector2(margin, margin + corner_radius))
	curve.add_point(Vector2(margin + corner_radius, margin))
	# canto superior direito
	curve.add_point(Vector2(w - margin - corner_radius, margin))
	curve.add_point(Vector2(w - margin, margin + corner_radius))
	# canto inferior direito
	curve.add_point(Vector2(w - margin, h - margin - corner_radius))
	curve.add_point(Vector2(w - margin - corner_radius, h - margin))

	curve.add_point(Vector2(w / 2, h - margin))

	return curve


func _play_card(card, zone):
	var p = card.global_position
	var parent = card.get_parent()
	parent.remove_child(card)
	zone.static_container.add_child(card)
	card.global_position = p
	card.rotation = 0


func _process_ai_turn(player: Player):
	await get_tree().create_timer(0.5).timeout
	if player.hand.get_child_count() > 0:
		_play_card(player, _game_stack)
	await get_tree().create_timer(0.5).timeout
	_end_turn()
