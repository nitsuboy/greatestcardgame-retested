class_name SimpleGameManager
extends GameManager

enum GameState { SETUP, TURN_START, PROCESS_TURN, END_GAME }

@export var _dealer: SimpleDealer
@export var _initial_hand_size: int = 7
@export var _players_node: Node2D
@export var _player: PackedScene

var state: GameState = GameState.SETUP

var _turn: int = -1
var _player_turn: int = -1
var _players_entities: Dictionary[int,Entity] = {}
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
func _log(what) -> void:
	$HBoxContainer/VBoxContainer2/RichTextLabel.add_text(what + "\n")


# RPC

@rpc("call_local")
func set_turn(player_id: int, sync_id: String) -> void:
	_player_turn = player_id
	for id in NetworkManager.players:
		var player_comp = EntitySystem.get_comp(_players_entities[id], PlayerComponent)
		if id == player_id:
			if id == multiplayer.get_unique_id():
				player_comp.hand.unblock_hand()
			player_comp.hand.raise_hand()
		else:
			if id == multiplayer.get_unique_id():
				player_comp.hand.block_hand(true, false)
			else:
				player_comp.hand.block_hand(true, true)
			player_comp.hand.lower_hand()

	confirm_state_helper(sync_id)


@rpc("call_local")
func _sync_single_card(card_data: Dictionary, player_id: int, sync_id: String) -> void:
	print(card_data)
	if card_data.is_empty():
		return
	DrawCardSystem.draw_single_card(player_id, card_data)

	confirm_state_helper(sync_id)


@rpc("call_local")
func _play_card_mult(card_entity_id: int, dp_entity_id: int, sync_id: String) -> void:
	var card_entity = Entity.all_entities[card_entity_id]
	var dp_entity = Entity.all_entities[dp_entity_id]
	var dp = EntitySystem.get_comp(dp_entity, NodeComponent).node
	var comp = EntitySystem.get_comp(card_entity, PlayableComponent)
	var dp_args = DropEventArgs.new(card_entity, dp)
	PlayCardSystem.play_card(card_entity, comp, dp_args)
	confirm_state_helper(sync_id)


@rpc("call_local")
func _discard_card_mult(card_entity_id: int, sync_id: String) -> void:
	var card_entity = Entity.all_entities[card_entity_id]
	var card_component = EntitySystem.get_comp(card_entity, NodeComponent)
	DiscardCardSystem.discard_card(card_entity, card_component)
	confirm_state_helper(sync_id)


func confirm_state_helper(sync_id):
	if multiplayer.is_server():
		NetworkManager._confirm_state(sync_id, 1)
		return
	NetworkManager.rpc_id(1, "_confirm_state", sync_id, multiplayer.get_unique_id())


## do certain action, only host can perform this function
func do_action(_sender: int, _action: int, _args) -> void:
	if not is_multiplayer_authority():
		return
	print("=== Action done ===")
	print("  Sender: %d | Action: %s" % [_sender, GameManager.Actions.keys()[_action]])
	print("  Args: %s" % [str(_args)])
	print("==============================")
	match _action:
		Actions.PLAY_CARD:
			_play_card_mult.rpc(_args[0], _args[1], send_and_wait())
			await NetworkManager.sync_confirmed
			_process_trigger_queue()
		Actions.DRAW_CARD:
			var num_cards = _args[0]
			var target = search_player(_args[1])
			for i in range(num_cards):
				var card_data = DrawCardSystem.draw_single_card_data()
				_sync_single_card.rpc(card_data, target, send_and_wait())
				await NetworkManager.sync_confirmed
			_process_trigger_queue()
		Actions.DISCARD_CARD:
			_discard_card_mult.rpc(_args[0], send_and_wait())
			await NetworkManager.sync_confirmed
			_process_trigger_queue()
		Actions.MODIFY_CARD:
			pass
		Actions.SKIP_TURN:
			next_turn(_args[0] - 1, false)
			_process_trigger_queue()
		Actions.END_TURN:
			change_state(GameState.PROCESS_TURN)
		_:
			push_warning("unknow action")


func _process_trigger_queue() -> void:
	if NetworkManager.has_trigger_actions():
		var action = NetworkManager.get_next_trigger_action()
		NetworkManager.request_action(
			NetworkManager.ActionWhere.GAME, action.action_type, action.args
		)
		return
	NetworkManager.request_action(NetworkManager.ActionWhere.GAME, GameManager.Actions.END_TURN)


# State machine
## Change the game state
func change_state(new_state: GameState) -> void:
	state = new_state
	print(GameState.keys()[state])
	match state:
		GameState.SETUP:
			_setup_game()
		GameState.TURN_START:
			_start_turn()
		GameState.PROCESS_TURN:
			_process_turn()
		GameState.END_GAME:
			pass


func _setup_game() -> void:
	_turn = 1
	_player_turn = 1
	$"../ActionZone".post_instantiate(0)
	_setup_players()

	if is_multiplayer_authority():
		_deal_initial_hands()

	change_state(GameState.TURN_START)


func _setup_players() -> void:
	var num_players = NetworkManager.players.size()
	var local_index = NetworkManager.players.keys().find(multiplayer.get_unique_id())

	for i in range(num_players):
		var player_id = NetworkManager.players.keys()[i]
		var t = fposmod((i - local_index) / float(num_players), 1.0)
		var p: Node2D = _player.instantiate()
		_players_node.add_child(p)
		p.post_instantiate(player_id)
		p.transform = get_point_on_path(_curve, t) * Transform2D(PI, Vector2.ZERO)
		p.scale = Vector2.ONE * .5
		_players_entities[player_id] = p.entity
		var player_comp = _get_player_comp(player_id)
		player_comp.debug.text = str(player_id)
		player_comp.hand.block_hand(true, true)


func _deal_initial_hands() -> void:
	for player_id in NetworkManager.players.keys():
		for i in range(_initial_hand_size):
			print("ciclo da carta numero %d" % (i + 1))
			var card_data = DrawCardSystem.draw_single_card_data()
			_sync_single_card.rpc(card_data, player_id, send_and_wait())
			await NetworkManager.sync_confirmed


func _get_player_comp(player_id: int) -> PlayerComponent:
	return EntitySystem.get_comp(_players_entities[player_id], PlayerComponent)


func next_turn(amount: int = 1, should_change: bool = true) -> void:
	var ids = NetworkManager.players.keys()
	var idx = ids.find(_player_turn)
	_player_turn = ids[(idx + amount) % ids.size()]
	if should_change:
		_turn += 1


func _start_turn() -> void:
	if not is_multiplayer_authority():
		return
	set_turn.rpc(_player_turn, send_and_wait())
	await NetworkManager.sync_confirmed


func _process_turn() -> void:
	_check_win()


func _check_win() -> void:
	next_turn()
	change_state(GameState.TURN_START)


func _end_turn() -> void:
	change_state(GameState.PROCESS_TURN)


# Misc


func search_player(skp: int) -> int:
	var ids = NetworkManager.players.keys()
	var idx = ids.find(_player_turn)
	return ids[(idx + skp) % ids.size()]


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
	var comp_hover: HoverableComponent = EntitySystem.get_comp(card_entity, HoverableComponent)
	comp_drag.locked = true
	comp_hover.locked = true


## handshake for confirmation
func send_and_wait() -> String:
	_state_track += 1
	var sync_id: String = str(_state_track)
	NetworkManager.start_sync_tracking(sync_id)
	return sync_id
