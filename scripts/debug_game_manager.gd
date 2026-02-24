class_name DebugGameManager
extends GameManager

enum GameState { SETUP, TURN_START, PROCESS_TURN, END_GAME }
enum Actions { PLAY_CARD, END_TURN, DRAW_CARD }

@export var _dealer: DebugDealer
@export var _player: Player

var state: GameState = GameState.SETUP

var _turn: int = -1
var _player_turn: int = -1
var _players_nodes: Dictionary = {}
var _state_track: int = 0
var _timer: Timer


func _init() -> void:
	Globals.debug = true
	NetworkManager.game = self


func _ready() -> void:
	_players_nodes[0] = $"../players/Player"
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
	var card_entity = Entity.all_entities[card_entity_id]
	var dp_entity = Entity.all_entities[dp_entity_id]
	var dp = EntitySystem.get_comp(dp_entity, NodeComponent).node
	var comp = EntitySystem.get_comp(card_entity, PlayableComponent)
	var dp_args = DropEventArgs.new(card_entity, dp)
	PlayCardSystem.play_card(card_entity, comp, dp_args)

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
			#await NetworkManager.sync_confirmed
			var e_args = PlayCardEventArgs.new(
				Entity.all_entities[_args[0]], Entity.all_entities[_args[1]]
			)
			var e = PlayCardEvent.new(e_args)
			e.start()
			#change_state(GameState.PROCESS_TURN)
		Actions.DRAW_CARD:
			var player = _players_nodes[_sender]
			var hand_cards = []
			for i in range(_args[0]):
				var card: Card = _dealer.draw_card()
				if card:
					player.add_card(card)
					hand_cards.append([card.card_data.id, card.entity.id])
					#if _sender != multiplayer.get_unique_id():
					#	card.flip(true)
			_sync_player_hand.rpc(hand_cards, _sender, send_and_wait())
			#await NetworkManager.sync_confirmed
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
	t = clamp(t, 0.0, 1.0)
	var length = curve.get_baked_length()
	var distance = t * length
	return curve.sample_baked_with_rotation(distance)


## handshake for confirmation
func send_and_wait() -> String:
	_state_track += 1
	var sync_id: String = str(_state_track)
	NetworkManager._pending_sync[sync_id] = []
	return sync_id


func _on_button_pressed() -> void:
	var card: Card = _dealer.draw_card()
	if card:
		_player.add_card(card)

	$"../DebugWindow/DebugMenu/EntityList".clear()
	for e in Entity.all_entities:
		$"../DebugWindow/DebugMenu/EntityList".add_item(str(e))
