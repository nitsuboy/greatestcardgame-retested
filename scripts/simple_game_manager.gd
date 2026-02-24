class_name SimpleGameManager
extends GameManager

enum GameState { SETUP, TURN_START, PROCESS_TURN, END_GAME }
enum Actions { PLAY_CARD, END_TURN }

@export var _dealer: SimpleDealer
@export var _initial_hand_size: int = 7
@export var _players_node: Node2D
@export var _player: PackedScene

var state: GameState = GameState.SETUP

var _turn: int = -1
var _player_turn: int = -1
var _players_nodes: Dictionary = {}
var _curve: Curve2D
var _state_track: int = 0
var _timer: Timer


func _init() -> void:
	NetworkManager.game = self


func _ready() -> void:
	_curve = make_rounded_square(50.0, 100.0)
	change_state(GameState.SETUP)
	_timer = Timer.new()
	add_child(_timer)
	_timer.one_shot = true


func _process(delta: float) -> void:
	if Globals.is_dragging:
		DragSystem.update(delta)


# Debug

@rpc("call_local")
func _log(what):
	$HBoxContainer/VBoxContainer2/RichTextLabel.add_text(what + "\n")


# RPC

@rpc("call_local")
func set_turn(player_id: int, sync_id: String) -> void:
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

	if multiplayer.is_server():
		return
	NetworkManager.rpc_id(1, "_confirm_state", sync_id, multiplayer.get_unique_id())


@rpc("call_remote")
func _sync_player_hand(hand_cards: Array, player_id: int, sync_id: String) -> void:
	var player = _players_nodes[player_id]
	for card_dup in hand_cards:
		var card: Card = _dealer.draw_card(card_dup[0], card_dup[1])
		player.add_card(card)
		if player_id != multiplayer.get_unique_id():
			card.flip(true)
	player.hand.block_hand()

	if multiplayer.is_server():
		return
	NetworkManager.rpc_id(1, "_confirm_state", sync_id, multiplayer.get_unique_id())


@rpc("call_local")
func play_card_mult(card_entity_id: int, dp_entity_id: int, sync_id: String) -> void:
	_state_track += 1
	print(Entity.all_entities)
	var card_entity = Entity.all_entities[card_entity_id]
	var dp_entity = Entity.all_entities[dp_entity_id]
	var card = EntitySystem.get_comp(card_entity, NodeComponent).node
	var dp = EntitySystem.get_comp(dp_entity, NodeComponent).node
	var comp = EntitySystem.get_comp(card_entity, PlayableComponent)
	var dp_args = DropEventArgs.new(card_entity, dp)
	PlayCardSystem.play_card(card_entity, comp, dp_args)
	card.flip(false)
	lock_card(card_entity)

	if multiplayer.is_server():
		return
	NetworkManager.rpc_id(1, "_confirm_state", sync_id, multiplayer.get_unique_id())


## do certain action, only host can perform this function
func do_action(_sender: int, _action: int, _args) -> void:
	if not is_multiplayer_authority():
		return
	match _action:
		Actions.PLAY_CARD:
			play_card_mult.rpc(_args[0], _args[1], send_and_wait())
			await NetworkManager.sync_confirmed
			if multiplayer.is_server():
				change_state(GameState.PROCESS_TURN)
		Actions.END_TURN:
			pass
		_:
			push_warning("unknow action")


# State machine
## Change the game state
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
	var num_players = NetworkManager.players.size()
	var local_index = NetworkManager.players.keys().find(multiplayer.get_unique_id())
	var aux = 0
	var id_count = 1
	$"../ActionZone".entity.id = 0
	$"../ActionZone".entity.all_entities[0] = $"../ActionZone".entity
	for player in NetworkManager.players:
		var t = fposmod((aux - local_index) / float(num_players), 1.0)
		aux += 1

		var transform = get_point_on_path(_curve, t)
		var p: Node2D = _player.instantiate()
		_players_node.add_child(p)
		p.get_child(0).entity.id = id_count
		p.get_child(0).entity.all_entities[id_count] = p.get_child(0).entity
		id_count += 1
		p.transform = transform
		p.scale = Vector2.ONE * .5
		p.rotate(PI)
		p.debug.text = str(player)
		_players_nodes[player] = p

	if not is_multiplayer_authority():
		return

	for player_id in NetworkManager.players.keys():
		var player = _players_nodes[player_id]
		var hand_cards = []
		for i in range(_initial_hand_size):
			var card: Card = _dealer.draw_card()
			if card:
				player.add_card(card)
				hand_cards.append([card.card_data.id, card.entity.id])
				if player_id != multiplayer.get_unique_id():
					card.flip(true)
		_sync_player_hand.rpc(hand_cards, player_id, send_and_wait())
		await NetworkManager.sync_confirmed

	change_state(GameState.TURN_START)


func next_turn():
	var ids = NetworkManager.players.keys()
	var idx = ids.find(_player_turn)
	_player_turn = ids[(idx + 1) % ids.size()]
	_turn += 1


func _start_turn():
	if not is_multiplayer_authority():
		return
	set_turn.rpc(_player_turn, send_and_wait())
	await NetworkManager.sync_confirmed


func _process_turn():
	_check_win()


func _check_win():
	next_turn()
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


func lock_card(card_entity) -> void:
	var comp_drag: DraggableComponent = EntitySystem.get_comp(card_entity, DraggableComponent)
	var comp_hover: HoverbleComponent = EntitySystem.get_comp(card_entity, HoverbleComponent)
	comp_drag.locked = true
	comp_hover.locked = true


## handshake for confirmation
func send_and_wait() -> String:
	_state_track += 1
	var sync_id: String = str(_state_track)
	NetworkManager._pending_sync[sync_id] = []
	return sync_id
