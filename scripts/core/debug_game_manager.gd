class_name DebugGameManager
extends GameManager

@export var _dealer: Dealer

var state: GameState = GameState.SETUP


func _init() -> void:
	Globals.debug = true
	Net.game = self
	InitSystems.initialize_all_systems()


func _ready() -> void:
	_register_prototypes()
	PrototypeSpawner.init_tree(get_tree().root)
	_players_entities[0] = $"../players/Player".entity
	_players_entities[1] = $"../players/Player".entity
	Players.add_player(1, {"id": 1, "state": 1})
	change_state(GameState.SETUP)


func _register_prototypes():
	PrototypeRegistry.register("play_zone", load("res://scenes/play_zone.tscn"))
	PrototypeRegistry.register("player", load("res://scenes/player.tscn"))
	PrototypeRegistry.register("teste", load("res://scenes/teste.tscn"))


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
	_turn_manager.set_player_turn(player_id)
	_hands.apply_turn_state(
		player_id, _players_entities, multiplayer.get_unique_id(), Players.get_player_ids()
	)
	confirm_state_helper(sync_id)


@rpc("call_local")
func _sync_single_card(card_data: Dictionary, player_id: int, sync_id: String) -> void:
	if card_data.is_empty():
		return
	DrawCardSystem.draw_single_card(player_id, card_data)
	confirm_state_helper(sync_id)


@rpc("call_local")
func _play_card_mult(card_entity_id: int, dp_entity_id: int, sync_id: String) -> void:
	var card_entity = EntityRegistry.get_entity(card_entity_id)
	var dp_entity = EntityRegistry.get_entity(dp_entity_id)
	var dp = EntitySystem.get_comp(dp_entity, NodeComponent).node
	PlayCardSystem.play_card(card_entity, dp)
	confirm_state_helper(sync_id)


@rpc("call_local")
func _spaw_mult(
	prototype_id: String,
	entity_id: int,
	spawn_data: Dictionary,
	parent_node: NodePath,
	sync_id: String
) -> void:
	var node = get_node(parent_node)
	PrototypeSpawner.spawn(prototype_id, entity_id, spawn_data, node)
	confirm_state_helper(sync_id)


@rpc("call_local")
func _discard_card_mult(card_entity_id: int, sync_id: String) -> void:
	var card_entity = EntityRegistry.get_entity(card_entity_id)
	var card_component = EntitySystem.get_comp(card_entity, NodeComponent)
	DiscardCardSystem.discard_card(card_entity, card_component)
	confirm_state_helper(sync_id)


func confirm_state_helper(sync_id) -> void:
	Net.rpc_id(1, "_confirm_state", sync_id, multiplayer.get_unique_id())


## do certain action, only host can perform this function
func do_action(_sender: int, _target: int, _action: int, _args) -> void:
	if not multiplayer.is_server():
		return
	print("==============================")
	print("  Sender: %d | Action: %s" % [_sender, GameManager.Actions.keys()[_action]])
	print("  Args: %s" % [str(_args)])
	match _action:
		Actions.START_TURN:
			set_turn.rpc(_turn_manager.player_turn, send_and_wait())
			await Net.sync_confirmed
		Actions.PLAY_CARD:
			var action = TriggerAction.new(_target, GameManager.Actions.END_TURN, [], _sender)
			Net.enqueue_trigger_action(action)
			_play_card_mult.rpc(_args[0], _args[1], send_and_wait())
			await Net.sync_confirmed
		Actions.DRAW_CARD, Actions.DRAW_CARD_UNSK:
			var num_cards = _args[0]
			var target = _turn_manager.search_player(Players.get_player_ids(), _args[1])
			for i in range(num_cards):
				var card_data = DrawCardSystem.draw_single_card_data()
				_sync_single_card.rpc(card_data, target, send_and_wait())
				await Net.sync_confirmed
		Actions.DISCARD_CARD:
			_discard_card_mult.rpc(_args[0], send_and_wait())
			await Net.sync_confirmed
		Actions.MODIFY_CARD:
			pass
		Actions.SKIP_TURN:
			pass
		Actions.SPAWN_PROTOTYPE:
			if not PrototypeRegistry.has(_args[0]):
				push_error("PrototypeSpawner: prototype '%s' not registered" % _args[0])
			else:
				var entity_id = EntityRegistry.calculate_next_entity_uid()
				_spaw_mult.rpc(
					_args[0], entity_id, _args[2], get_parent().get_path(), send_and_wait()
				)
				await Net.sync_confirmed
		Actions.END_TURN:
			change_state(GameState.PROCESS_TURN)
		_:
			push_warning("unknow action")
	_process_trigger_queue()


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
	_turn_manager.turn = 1
	_turn_manager.player_turn = 1

	change_state(GameState.TURN_START)


func _start_turn() -> void:
	if not multiplayer.is_server():
		return
	set_turn.rpc(_turn_manager.player_turn, send_and_wait())
	await Net.sync_confirmed


func _process_turn() -> void:
	_check_win()


func _check_win() -> void:
	_turn_manager.next_turn(Players.get_player_ids())
	change_state(GameState.TURN_START)


func _end_turn() -> void:
	change_state(GameState.PROCESS_TURN)


# Misc


func get_player_entity(player_id: int) -> Entity:
	return _players_entities.get(player_id)


## handshake for confirmation
func send_and_wait() -> String:
	_state_track += 1
	var sync_id: String = str(_state_track)
	Net.start_sync_tracking(sync_id)
	return sync_id


func is_server() -> bool:
	return multiplayer.is_server()


func _on_button_pressed() -> void:
	var card: Card = _dealer.draw_card()
	if card:
		var player_comp = EntitySystem.get_comp(_players_entities[0], PlayerComponent)

		player_comp.hand.add_card(card)

	$"../DebugWindow/DebugMenu/EntityList".clear()
	for e in EntityRegistry.get_current_entities():
		$"../DebugWindow/DebugMenu/EntityList".add_item(str(e))
