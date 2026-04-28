class_name TurnSystem
extends System


static func initialize():
	EventSystem.inscrever_evento_local(
		SkipTurnOnTriggerComponent, TriggerEvent, Callable(TurnSystem, "on_trigger")
	)


static func on_trigger(_entity: Entity, _comp: SkipTurnOnTriggerComponent, _args: TriggerEvent):
	if not _comp.keys_in.has(_args.key_out):
		return
	var action = TriggerSystem.TriggerAction.new(
		Net.multiplayer.get_unique_id(), GameManager.Actions.SKIP_TURN, [_comp.num_of_turns]
	)
	Net.enqueue_trigger_action(action)
	print("    [ENQUEUED] SKIP_TURN | Turns: %d" % _comp.num_of_turns)


static func change_turn_request(num_of_turns: int) -> void:
	Net.client_request_action(
		Net.multiplayer.get_unique_id(),
		Net.ActionWhere.GAME,
		GameManager.Actions.SKIP_TURN,
		num_of_turns
	)
