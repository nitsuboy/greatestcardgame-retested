class_name SimpleGameManager
extends GameManager

@export var _bg: BackgroundController
@export var _initial_hand_size: int = 7
@export var _players_node: Node2D
@export var _game_node: Node

var state: GameState = GameState.SETUP

var _curve: Curve2D


func _init() -> void:
	Net.game = self
	InitSystems.initialize_all_systems()


func _ready() -> void:
	_curve = CurveHelper.make_rounded_square(get_viewport().get_visible_rect().size, 50.0, 100.0)
	_register_prototypes()
	PrototypeSpawner.init_tree(get_tree().root)
	change_state(GameState.SETUP)


func _register_prototypes():
	PrototypeRegistry.register("card", load("res://scenes/card.tscn"))
	PrototypeRegistry.register("play_zone", load("res://scenes/play_zone.tscn"))
	PrototypeRegistry.register("player", load("res://scenes/player.tscn"))
	PrototypeRegistry.register("teste", load("res://scenes/teste.tscn"))
	PrototypeRegistry.register("color_picker", load("res://scenes/color_picker.tscn"))


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
	var cp = EntitySystem.get_comp(card_entity, NodeComponent).node.card_data.card_color
	var cr = EntitySystem.get_comp(card_entity, NodeComponent).node.card_data.card_value
	_bg.set_card_color(cp)
	if cr == Card.CardValue.REVERSE:
		_turn_manager.direction = !_turn_manager.direction
		_bg.set_direction(_turn_manager.direction)

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
	if spawn_data.has("target"):
		if spawn_data["target"].has(multiplayer.get_unique_id()):
			PrototypeSpawner.spawn(prototype_id, entity_id, spawn_data, node)
	else:
		PrototypeSpawner.spawn(prototype_id, entity_id, spawn_data, node)
	confirm_state_helper(sync_id)


@rpc("call_local")
func _discard_card_mult(card_entity_id: int, sync_id: String) -> void:
	var card_entity = EntityRegistry.get_entity(card_entity_id)
	var card_component = EntitySystem.get_comp(card_entity, NodeComponent)
	DiscardCardSystem.discard_card(card_entity, card_component)
	confirm_state_helper(sync_id)


@rpc("call_local")
func _end_match(message: String) -> void:
	return_to_lobby(message)


func on_player_disconnected(player_id: int) -> void:
	if not multiplayer.is_server():
		return

	print("Jogador %d desconectou durante o jogo" % player_id)

	# 1. Descarta todas as cartas do jogador
	_discard_player_cards(player_id)

	# 2. Remove a entidade do dicionário
	_players_entities.erase(player_id)


func _discard_player_cards(player_id: int) -> void:
	var player_comp = _get_player_comp(player_id)
	if not player_comp or not player_comp.hand:
		return

	for card in player_comp.hand.get_children():
		if card is Card:
			_dealer.discard_card(card)


func return_to_lobby(message: String) -> void:
	print(message)

	# Limpa estado do jogo
	EntityRegistry.clear_entities()
	_players_entities.clear()
	_turn_manager.reset()

	_game_node.queue_free()

	if Net.lobby:
		Net.lobby.visible = true
		Net.lobby._stop_server()  # reseta botões para estado pré-conexão
		Net.lobby.refresh_lobby_list()
		Net.lobby.call_deferred("warning_dialog", message)

	# Limpa estado de rede
	Net.close_network()


func confirm_state_helper(sync_id) -> void:
	Net.rpc_id(1, "_confirm_state", sync_id, multiplayer.get_unique_id())


func _dispatch_action(
	_sender: int, _target: int, _action: int, _args, result: ValidationResult
) -> void:
	match _action:
		Actions.START_TURN:
			await _on_start_turn(_sender, _target, _args, result)
		Actions.PLAY_CARD:
			await _on_play_card(_sender, _target, _args)
		Actions.DRAW_CARD, Actions.DRAW_CARD_UNSK:
			await _on_draw_card(_sender, _target, _args)
		Actions.DISCARD_CARD:
			await _on_discard_card(_args)
		Actions.MODIFY_CARD:
			pass
		Actions.SKIP_TURN:
			_on_skip_turn(_args)
		Actions.SPAWN_PROTOTYPE:
			await _on_spawn_prototype(_args)
		Actions.END_TURN:
			change_state(GameState.PROCESS_TURN)
		_:
			push_warning("unknow action")


func _on_start_turn(_sender: int, _target: int, _args, result: ValidationResult) -> void:
	if result.data.has("num_cards"):
		Net.request_action(
			_sender,
			_target,
			Net.ActionWhere.GAME,
			Actions.DRAW_CARD_UNSK,
			[result.data["num_cards"], 0]
		)
	set_turn.rpc(_turn_manager.player_turn, send_and_wait())
	await Net.sync_confirmed


func _on_play_card(_sender: int, _target: int, _args) -> void:
	var action = TriggerAction.new(_target, GameManager.Actions.END_TURN, [], _sender)
	TriggerRegistry.enqueue_trigger_action(action)
	_play_card_mult.rpc(_args[0], _args[1], send_and_wait())
	await Net.sync_confirmed


func _on_draw_card(_sender: int, _target: int, _args) -> void:
	var num_cards = _args[0]
	var target = _turn_manager.search_player(Players.get_player_ids(), _args[1])
	for i in range(num_cards):
		var card_data = DrawCardSystem.draw_single_card_data()
		_sync_single_card.rpc(card_data, target, send_and_wait())
		await Net.sync_confirmed


func _on_discard_card(_args) -> void:
	_discard_card_mult.rpc(_args[0], send_and_wait())
	await Net.sync_confirmed


func _on_skip_turn(_args) -> void:
	_turn_manager.next_turn(Players.get_player_ids(), _args[0] - 1, false)


func _on_spawn_prototype(_args) -> void:
	if not PrototypeRegistry.has(_args[0]):
		push_error("PrototypeSpawner: prototype '%s' not registered" % _args[0])
		return
	var entity_id = EntityRegistry.calculate_next_entity_uid()
	if _args[2].has("target"):
		var target: Array = []
		for i in _args[2]["target"]:
			target.append(_turn_manager.search_player(Players.get_player_ids(), i))
		_args[2]["target"] = target
	_spaw_mult.rpc(_args[0], entity_id, _args[2], get_parent().get_path(), send_and_wait())
	await Net.sync_confirmed


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

	if multiplayer.is_server():
		_setup_players.rpc(
			send_and_wait(), EntityRegistry.get_empty_uid(Players.get_player_ids().size())
		)
		await Net.sync_confirmed
		await _deal_initial_hands()
		change_state(GameState.TURN_START)


@rpc("call_local")
func _setup_players(sync_id: String, ids: Array[int]) -> void:
	var num_players = Players.get_player_ids().size()
	var local_index = Players.get_player_ids().find(multiplayer.get_unique_id())

	for i in range(num_players):
		var player_id = Players.get_player_ids()[i]
		var t = fposmod((i - local_index) / float(num_players), 1.0)
		PrototypeSpawner.spawn(
			"player",
			ids[i],
			{
				"name": Players.get_player(player_id),
				"transform":
				CurveHelper.get_point_on_path(_curve, t) * Transform2D(PI, Vector2.ZERO),
				"scale": Vector2.ONE * .5
			},
			_players_node
		)
		_players_entities[player_id] = EntityRegistry.get_entity(ids[i])
	confirm_state_helper(sync_id)


func _deal_initial_hands() -> void:
	for player_id in Players.get_player_ids():
		for i in range(_initial_hand_size):
			var card_data = DrawCardSystem.draw_single_card_data()
			_sync_single_card.rpc(card_data, player_id, send_and_wait())
			await Net.sync_confirmed


func _get_player_comp(player_id: int) -> PlayerComponent:
	return EntitySystem.get_comp(_players_entities[player_id], PlayerComponent)


func _start_turn() -> void:
	if not multiplayer.is_server():
		return
	Net.request_action(
		_turn_manager.player_turn,
		_turn_manager.player_turn,
		Net.ActionWhere.GAME,
		GameManager.Actions.START_TURN
	)


func _process_turn() -> void:
	_check_win()


func _check_win() -> void:
	_turn_manager.next_turn(Players.get_player_ids())
	change_state(GameState.TURN_START)


func _end_turn() -> void:
	change_state(GameState.PROCESS_TURN)


func search_player(offset: int = 0) -> int:
	return _turn_manager.search_player(Players.get_player_ids(), offset)


# Misc


func lock_card(card_entity) -> void:
	var comp_drag: DraggableComponent = EntitySystem.get_comp(card_entity, DraggableComponent)
	var comp_hover: HoverableComponent = EntitySystem.get_comp(card_entity, HoverableComponent)
	comp_drag.locked = true
	comp_hover.locked = true


## handshake for confirmation
func send_and_wait() -> String:
	_state_track += 1
	var sync_id: String = str(_state_track)
	Net.start_sync_tracking(sync_id)
	return sync_id


## Getters publicos (para API)
func get_dealer() -> Dealer:
	return _dealer


func get_player_entity(player_id: int) -> Entity:
	return _players_entities.get(player_id)


func get_player_hand(player_id: int) -> Node:
	var player_entity = get_player_entity(player_id)
	if player_entity:
		var player_comp = EntitySystem.get_comp(player_entity, PlayerComponent)
		if player_comp:
			return player_comp.hand
	return null


func peek_card(offset: int) -> CardData:
	if _dealer:
		return _dealer.peek_deck(offset)
	return null


func is_server() -> bool:
	return multiplayer.is_server()
