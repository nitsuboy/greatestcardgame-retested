class_name PlaySystem
extends SystemNode

var _turn_entity: int = -1
var _seq: int = 0
var _last_card_color: int = -1
var _last_card_value: int = -1


func init_system() -> void:
	Remote.action_received.connect(_on_action)
	world.events.on_component_added.connect(_check_turn_entity)


func _check_turn_entity(_entity: int, type: Script) -> void:
	if type == TurnComponent and _turn_entity == -1:
		_turn_entity = _entity


func _on_action(sender: int, action: String, data: Dictionary) -> void:
	if action != "play_card":
		return
	if not multiplayer.is_server():
		return

	var entity = data.entity
	if not world.entities.exists(entity):
		return
	if not world.has_component(entity, CardComponent):
		return

	var card = world.get_component(entity, CardComponent)
	var turn = world.get_component(_turn_entity, TurnComponent) if _turn_entity != -1 else null

	if not _validate(turn, sender, card):
		return

	# Executa
	card.zone_id = 999  # zone_id do play_zone
	card.face_up = true
	_last_card_color = card.color
	_last_card_value = card.value

	var batch = [
		{"entity": entity, "type": ScriptCache.get_path(CardComponent), "data": card.to_dict()}
	]

	# Efeitos de cartas especiais
	if card.value == 10:  # SKIP
		var skip = {
			"entity": _turn_entity,
			"type": ScriptCache.get_path(TurnComponent),
			"data": turn.to_dict()
		}
		# skip será processado pelo turn_system via action separada
		Remote.send("skip_turn", {"amount": 1})
	elif card.value == 11:  # REVERSE
		turn.direction = 1 if turn.direction == -1 else -1
		batch.append(
			{
				"entity": _turn_entity,
				"type": ScriptCache.get_path(TurnComponent),
				"data": turn.to_dict()
			}
		)
	elif card.value == 12:  # +2
		Remote.send("draw_card", {"player": _next_player(turn), "amount": 2})
	elif card.value == 13:  # +4
		Remote.send("draw_card", {"player": _next_player(turn), "amount": 4})

	var sync_id = "play_%d" % _seq
	_seq += 1
	replicator.push_state(batch, sync_id)


func _validate(turn: TurnComponent, sender: int, card: CardComponent) -> bool:
	if turn and turn.current_player != sender:
		return false
	if _last_card_color == -1:
		return true
	return card.color == _last_card_color or card.color == 4 or card.value == _last_card_value


func _next_player(turn: TurnComponent) -> int:
	var ids = Players.get_player_ids()
	var idx = ids.find(turn.current_player)
	var next = (idx + turn.direction + ids.size()) % ids.size()
	return ids[next]
