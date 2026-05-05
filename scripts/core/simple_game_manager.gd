class_name SimpleGameManager
extends GameManager

@export var _dealer: Dealer
@export var _rules: Rules
@export var _initial_hand_size: int = 7
@export var _players_node: Node2D
@export var _player: PackedScene

var state: GameState = GameState.SETUP

var _turn: int = -1
var _player_turn: int = -1
var _curve: Curve2D
var _direction: bool = true


func _init() -> void:
	Net.game = self


func _ready() -> void:
	_curve = make_rounded_square(50.0, 100.0)
	_register_prototypes()
	PrototypeSpawner.init_tree(get_tree().root)
	InitSystems.initialize_all_systems()
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
	_player_turn = player_id
	for id in Players.get_player_ids():
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
	match cp:
		Card.CardColor.YELLOW:
			$"../Background/ColorRect".set_color_shader(Color.YELLOW)
		Card.CardColor.BLUE:
			$"../Background/ColorRect".set_color_shader(Color.BLUE)
		Card.CardColor.RED:
			$"../Background/ColorRect".set_color_shader(Color.RED)
		Card.CardColor.GREEN:
			$"../Background/ColorRect".set_color_shader(Color.GREEN)
		_:
			$"../Background/ColorRect".set_color_shader(Color.ANTIQUE_WHITE)
	if cr == Card.CardValue.REVERSE:
		_direction = !_direction
		$"../Background/ColorRect".change_direction(_direction)

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


func confirm_state_helper(sync_id) -> void:
	Net.rpc_id(1, "_confirm_state", sync_id, multiplayer.get_unique_id())


## do certain action, only host can perform this function
func do_action(_sender: int, _target: int, _action: int, _args) -> void:
	if not multiplayer.is_server():
		return
	print("==============================")
	print("  Sender: %d | Action: %s" % [_sender, GameManager.Actions.keys()[_action]])
	print("  Args: %s" % [str(_args)])
	var vlc = ValidationContext.new()
	vlc.action = _action
	vlc.player_id = _sender
	vlc.target_id = _target
	vlc.args = _args
	var result: ValidationResult = _rules.validate(vlc)
	if result.is_valid:
		match _action:
			Actions.START_TURN:
				if result.data.has("num_cards"):
					Net.request_action(
						_sender,
						_target,
						Net.ActionWhere.GAME,
						Actions.DRAW_CARD_UNSK,
						[result.data["num_cards"], 0]
					)
				set_turn.rpc(_player_turn, send_and_wait())
				await Net.sync_confirmed
			Actions.PLAY_CARD:
				var action = TriggerSystem.TriggerAction.new(
					_target, GameManager.Actions.END_TURN, [], _sender
				)
				Net.enqueue_trigger_action(action)
				_play_card_mult.rpc(_args[0], _args[1], send_and_wait())
				await Net.sync_confirmed
			Actions.DRAW_CARD, Actions.DRAW_CARD_UNSK:
				var num_cards = _args[0]
				var target = search_player(_args[1])
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
				next_turn(_args[0] - 1, false)
			Actions.END_TURN:
				change_state(GameState.PROCESS_TURN)
			Actions.SPAWN_PROTOTYPE:
				if not PrototypeRegistry.has(_args[0]):
					push_error("PrototypeSpawner: prototype '%s' not registered" % _args[0])
				else:
					var entity_id = EntityRegistry.calculate_next_id()
					if _args[2].has("target"):
						var target: Array = []
						for i in _args[2]["target"]:
							target.append(search_player(i))
						_args[2]["target"] = target
					_spaw_mult.rpc(
						_args[0], entity_id, _args[2], get_parent().get_path(), send_and_wait()
					)
					await Net.sync_confirmed
			_:
				push_warning("unknow action")
	else:
		print(result.rejected_reason)
	_process_trigger_queue()


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

	if multiplayer.is_server():
		_setup_players.rpc(send_and_wait())
		await Net.sync_confirmed
		await _deal_initial_hands()
		change_state(GameState.TURN_START)


@rpc("call_local")
func _setup_players(sync_id: String) -> void:
	var num_players = Players.get_player_ids().size()
	var local_index = Players.get_player_ids().find(multiplayer.get_unique_id())

	for i in range(num_players):
		var player_id = Players.get_player_ids()[i]
		var t = fposmod((i - local_index) / float(num_players), 1.0)
		var p: Node2D = _player.instantiate()
		_players_node.add_child(p)
		p.transform = get_point_on_path(_curve, t) * Transform2D(PI, Vector2.ZERO)
		p.scale = Vector2.ONE * .5
		p.post_instantiate(player_id)
		_players_entities[player_id] = p.entity
		var player_comp = _get_player_comp(player_id)
		player_comp.debug.text = str(Players.get_player(player_id)["name"])
		player_comp.debug.rotation = -p.rotation
		player_comp.hand.block_hand(true, true)
	confirm_state_helper(sync_id)


func _deal_initial_hands() -> void:
	for player_id in Players.get_player_ids():
		for i in range(_initial_hand_size):
			var card_data = DrawCardSystem.draw_single_card_data()
			_sync_single_card.rpc(card_data, player_id, send_and_wait())
			await Net.sync_confirmed


func _get_player_comp(player_id: int) -> PlayerComponent:
	return EntitySystem.get_comp(_players_entities[player_id], PlayerComponent)


func next_turn(amount: int = 1, should_change: bool = true) -> void:
	var ids = Players.get_player_ids()
	var idx = ids.find(_player_turn)
	if _direction:
		_player_turn = ids[(idx + amount) % ids.size()]
	else:
		_player_turn = ids[(idx + amount + ids.size()) % ids.size()]
	if should_change:
		_turn += 1


func _start_turn() -> void:
	if not multiplayer.is_server():
		return
	Net.request_action(
		_player_turn, _player_turn, Net.ActionWhere.GAME, GameManager.Actions.START_TURN
	)


func _process_turn() -> void:
	_check_win()


func _check_win() -> void:
	next_turn()
	change_state(GameState.TURN_START)


func _end_turn() -> void:
	change_state(GameState.PROCESS_TURN)


# Misc


func search_player(offset: int) -> int:
	var ids = Players.get_player_ids()
	var idx = ids.find(_player_turn)
	return ids[(idx + offset) % ids.size()]


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
