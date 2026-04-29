class_name DebugGameManager
extends GameManager

enum GameState { SETUP, TURN_START, PROCESS_TURN, END_GAME }

@export var _dealer: Dealer

var state: GameState = GameState.SETUP

var _turn: int = -1
var _player_turn: int = -1
var _players_entities: Dictionary[int,Entity] = {}
var _state_track: int = 0
var _timer: Timer


func _init() -> void:
	Globals.debug = true
	Net.game = self


func _ready() -> void:
	$"../players/Player".post_instantiate()
	$"../ActionZone".post_instantiate()
	$"../ActionZone2".post_instantiate()
	$"../ActionZone3".post_instantiate()
	_players_entities[0] = $"../players/Player".entity
	_players_entities[1] = $"../players/Player".entity
	Players.add_player(1, {"id": 1, "state": 1})
	change_state(GameState.SETUP)
	_timer = Timer.new()
	add_child(_timer)
	_timer.one_shot = true
	InitSystems.initialize_all_systems()


func _process(delta: float) -> void:
	if Globals.is_dragging:
		DragSystem.update(delta)


func get_dealer() -> Dealer:
	return _dealer

# Debug

@rpc("call_local")
func _log(what) -> void:
	$HBoxContainer/VBoxContainer2/RichTextLabel.add_text(what + "\n")


# RPC

@rpc("call_local")
func set_turn(player_id: int, sync_id: String) -> void:
	_player_turn = player_id
	for id in Players.get_player_ids():
		var player_comp = EntitySystem.get_comp(_players_entities[id], PlayerComponent)
		if id == player_id:
			if id == multiplayer.get_unique_id():
				player_comp.hand.unblock_hand()
			player_comp.hand.raise_hand()
		else:
			player_comp.hand.block_hand()
			player_comp.hand.lower_hand()

	if multiplayer.is_server():
		return
	Net.rpc_id(1, "_confirm_state", sync_id, multiplayer.get_unique_id())


@rpc("call_remote")
func _sync_player_hand(hand_cards: Array, player_id: int, sync_id: String) -> void:
	var player_comp = EntitySystem.get_comp(_players_entities[player_id], PlayerComponent)
	for card_dup in hand_cards:
		var card: Card = _dealer.draw_card(card_dup["id"], card_dup["entity_id"])
		player_comp.hand.add_card(card)
		if player_id != multiplayer.get_unique_id():
			card.flip(true)
	player_comp.hand.block_hand()

	if multiplayer.is_server():
		return
	Net.rpc_id(1, "_confirm_state", sync_id, multiplayer.get_unique_id())


@rpc("call_local")
func _sync_single_card(card_data: Dictionary, player_id: int, sync_id: String) -> void:
	if card_data.is_empty():
		return

	var player_comp = EntitySystem.get_comp(_players_entities[player_id], PlayerComponent)
	var card: Card = _dealer.draw_card(card_data["id"], card_data["entity_id"])
	player_comp.hand.add_card(card)

	if player_id != multiplayer.get_unique_id():
		card.flip(true)

	if multiplayer.is_server():
		return
	Net.rpc_id(1, "_confirm_state", sync_id, multiplayer.get_unique_id())


@rpc("call_local")
func play_card_mult(card_entity_id: int, dp_entity_id: int, sync_id: String) -> void:
	var card_entity = Entity.get_entity(card_entity_id)
	var dp_entity = Entity.get_entity(dp_entity_id)
	var dp = EntitySystem.get_comp(dp_entity, NodeComponent).node
	var comp = EntitySystem.get_comp(card_entity, PlayableComponent)
	PlayCardSystem.play_card(card_entity, dp)

	if multiplayer.is_server():
		return
	Net.rpc_id(1, "_confirm_state", sync_id, multiplayer.get_unique_id())


@rpc("call_local")
func discard_card_mult(card_entity_id: int, sync_id: String) -> void:
	var card_entity = Entity.get_entity(card_entity_id)
	var card_component = EntitySystem.get_comp(card_entity, NodeComponent)
	DiscardCardSystem.discard_card(card_entity, card_component)

	if multiplayer.is_server():
		return
	Net.rpc_id(1, "_confirm_state", sync_id, multiplayer.get_unique_id())


## do certain action, only host can perform this function
func do_action(_sender: int, _target: int, _action: int, _args) -> void:
	if not multiplayer.is_server():
		return
	match _action:
		Actions.PLAY_CARD:
			play_card_mult.rpc(_args[0], _args[1], send_and_wait())
			_process_trigger_queue()
		Actions.DRAW_CARD:
			var num_cards = _args[0]
			var target = search_player(_args[1])
			for i in range(num_cards):
				var card_data = DrawCardSystem.draw_single_card_data()
				_sync_single_card.rpc(card_data, target, send_and_wait())
			_process_trigger_queue()
		Actions.DISCARD_CARD:
			discard_card_mult.rpc(_args[0], send_and_wait())
			_process_trigger_queue()
		Actions.MODIFY_CARD:
			pass
		Actions.END_TURN:
			pass
		_:
			push_warning("unknow action")


func _process_trigger_queue() -> void:
	if Net.has_trigger_actions():
		var action = Net.get_next_trigger_action()
		Net.request_action(
			action.player_id,
			action.target_id,
			Net.ActionWhere.GAME,
			action.action_type,
			action.args
		)


# State machine
## Change the game state
func change_state(new_state: GameState) -> void:
	state = new_state
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

	change_state(GameState.TURN_START)


func next_turn() -> void:
	var ids = Players.get_player_ids()
	var idx = ids.find(_player_turn)
	_player_turn = ids[(idx + 1) % ids.size()]
	_turn += 1


func _start_turn() -> void:
	if not multiplayer.is_server():
		return
	set_turn.rpc(_player_turn, send_and_wait())
	await Net.sync_confirmed


func _process_turn() -> void:
	_check_win()


func _check_win() -> void:
	next_turn()
	change_state(GameState.TURN_START)


func _end_turn() -> void:
	change_state(GameState.PROCESS_TURN)


# Misc


func search_player(skp: int) -> int:
	var ids = Players.get_player_ids()
	var idx = ids.find(_player_turn)
	return ids[(idx + skp) % ids.size()]


func get_point_on_path(curve: Curve2D, t: float) -> Transform2D:
	t = clamp(t, 0.0, 1.0)
	var length = curve.get_baked_length()
	var distance = t * length
	return curve.sample_baked_with_rotation(distance)


## handshake for confirmation
func send_and_wait() -> String:
	_state_track += 1
	var sync_id: String = str(_state_track)
	Net.start_sync_tracking(sync_id)
	return sync_id


func _on_button_pressed() -> void:
	var card: Card = _dealer.draw_card()
	if card:
		var player_comp = EntitySystem.get_comp(_players_entities[0], PlayerComponent)

		player_comp.hand.add_card(card)

	$"../DebugWindow/DebugMenu/EntityList".clear()
	for e in Entity.get_all_entities():
		$"../DebugWindow/DebugMenu/EntityList".add_item(str(e))
