class_name SimpleGameManager
extends Node

enum GameState { SETUP, TURN_START, PROCESS_TURN, END_GAME }
enum Actions { PLAY }

@export var _dealer: SimpleDealer
@export var _initial_hand_size: int = 3
@export var _players_node: Node2D
@export var _player: PackedScene

var state: GameState = GameState.SETUP

var _turn: int = -1
var _player_turn: int = -1
var _players_nodes: Dictionary = {}
var _curve: Curve2D
var _state_track: int = 0


func _init() -> void:
	NetworkManager.game = self


func _ready() -> void:
	_curve = make_rounded_square(50.0, 150.0)
	change_state(GameState.SETUP)


func _process(delta: float) -> void:
	if Globals.is_dragging:
		DragSystem.update(delta)


# Debug

@rpc("call_local")
func _log(what):
	$HBoxContainer/VBoxContainer2/RichTextLabel.add_text(what + "\n")


# RPC

@rpc("call_local")
func set_turn(player_id: int):
	_player_turn = player_id
	for id in NetworkManager.players:
		var player = _players_nodes[id]
		if id == player_id:
			if id == multiplayer.get_unique_id():
				player.hand.unblock_hand()
			player.hand.raise_hand()
		else:
			player.hand.block_hand()
			player.hand.lower_hand()


## do certain action, only server host can perform this function
func do_action(_sender: int, _action: int, _args) -> void:
	if not is_multiplayer_authority():
		return
	match _action:
		0:
			play_card_mult.rpc(_args[0], _args[1])
		1:
			pass
		_:
			push_warning("unknow action")


# State machine

@rpc("call_local")
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
	var aux = NetworkManager.players.keys().find(multiplayer.get_unique_id())
	var id_count = 1
	for player in NetworkManager.players:
		var p: Node2D = _player.instantiate()
		var transform = get_point_on_path(_curve, aux / float(NetworkManager.players.size()))
		aux = (aux + 1) % NetworkManager.players.size()
		_players_node.add_child(p)
		p.get_child(0).entity.id = id_count
		p.get_child(0).entity.all_entities[id_count] = p.get_child(0).entity
		id_count += 1
		p.transform = transform
		p.scale = Vector2.ONE * .7
		p.rotate(PI)
		p.debug.text = str(player)
		_players_nodes[player] = p

	if not is_multiplayer_authority():
		return

	await send_and_wait()

	for player_id in NetworkManager.players.keys():
		var player = _players_nodes[player_id]
		var hand_cards = []
		for i in range(_initial_hand_size):
			var card: Card = _dealer.draw_card()
			player.add_card(card)
			if card:
				hand_cards.append([card.card_data.id, card.entity.id])
		print(hand_cards)
		rpc("_sync_player_hand", hand_cards, player_id)

	await send_and_wait()

	change_state(GameState.TURN_START)


@rpc("call_remote")
func _sync_player_hand(hand_cards: Array, player_id: int) -> void:
	print(hand_cards)
	var player = _players_nodes[player_id]
	for card_dup in hand_cards:
		print(card_dup)
		var card: Card = _dealer.draw_card(card_dup[0], card_dup[1])
		print(card.entity.id)
		player.add_card(card)
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


## handshake for confirmation
func send_and_wait() -> void:
	_state_track += 1
	var sync_id = str(_state_track)
	NetworkManager._pending_sync[sync_id] = []
	NetworkManager.rpc("_receive_state", sync_id)

	# espera o sinal antes de continuar
	await NetworkManager.sync_confirmed
	print("Todos confirmaram, continuando...")


@rpc("call_local")
func play_card_mult(card_entity_id, dp_entity_id) -> void:
	print(Entity.all_entities)
	var card_entity = Entity.all_entities[card_entity_id]
	var dp_entity = Entity.all_entities[dp_entity_id]
	var dp = EntitySystem.get_comp(dp_entity, NodeComponent).node
	print(dp)
	var comp = EntitySystem.get_comp(card_entity, PlayableComponent)
	var drop = DropEventArgs.new(card_entity, EntitySystem.get_comp(dp_entity, NodeComponent).node)
	PlayCardSystem.play_card(card_entity, comp, drop)
