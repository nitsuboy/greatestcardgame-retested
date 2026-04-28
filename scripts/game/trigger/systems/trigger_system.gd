class_name TriggerSystem
extends System

static func initialize():
	EventSystem.InscreverEventoLocal(TriggerOnDiscardedComponent, DiscardCardEvent, Callable(TriggerSystem, "try_trigger"))
	EventSystem.InscreverEventoLocal(TriggerOnPlayedComponent, PlayCardEvent, Callable(TriggerSystem, "try_trigger"))
	EventSystem.InscreverEventoLocal(TriggerOnDrawComponent, DrawCardEvent, Callable(TriggerSystem, "try_trigger"))
	EventSystem.InscreverEventoLocal(TriggerOnPreDrawComponent, PreDrawCardEvent, Callable(TriggerSystem, "try_trigger"))
	

static func try_trigger(entity: Entity, comp: TriggerOnComponent, _args: Event) -> void:
	print("=== TriggerSystem: try_trigger ===")
	print("  Entity: %d | Comp key_out: %s" % [entity.id, comp.key_out])
	
	var ev = TriggerEvent.new(comp.key_out)
	EventSystem.IniciarEventoLocal(entity, ev)

	var on_trigger_comps = EntitySystem.get_comps_related(entity, OnTriggerComponent)

	for on_trigger_comp in on_trigger_comps:
		if on_trigger_comp.keys_in.has(comp.key_out):
			var comp_name = on_trigger_comp.get_script().get_global_name().split("/")[-1]
			print("  [FOUND] Trigger: %s | Key: %s" % [comp_name, comp.key_out])

			match on_trigger_comp.get_script():
				LogOnTriggerComponent:
					var log_comp = on_trigger_comp as LogOnTriggerComponent
					print("    [LOG] %s" % log_comp.msg)

				DrawOnTriggerComponent:
					var draw_comp = on_trigger_comp as DrawOnTriggerComponent
					var game = Net.game
					var action = TriggerAction.new(
						game.search_player(draw_comp.player),
						GameManager.Actions.DRAW_CARD,
						[draw_comp.number_of_cards, draw_comp.player]
					)
					Net.enqueue_trigger_action(action)
					print(
						(
							"    [ENQUEUED] DRAW_CARD | Cards: %d | Target offset: %d"
							% [draw_comp.number_of_cards, draw_comp.player]
						)
					)

				SkipTurnOnTriggerComponent:
					var skip_comp = on_trigger_comp as SkipTurnOnTriggerComponent
					var action = TriggerAction.new(
						Net.multiplayer.get_unique_id(),
						GameManager.Actions.SKIP_TURN,
						[skip_comp.num_of_turns]
					)
					Net.enqueue_trigger_action(action)
					print("    [ENQUEUED] SKIP_TURN | Turns: %d" % skip_comp.num_of_turns)

				_:
					push_warning("not in the action list: %s" % str(on_trigger_comp.get_script()))

	print("  Queue size: %d" % Net.get_trigger_queue_size())
	if not Net.is_trigger_queue_empty():
		print("  Actions queued:")
		var queue = Net.get_trigger_action_queue()
		for i in queue:
			print("    - %s | Args: %s" % [GameManager.Actions.keys()[i.action_type], str(i.args)])
	print("==============================")


class TriggerAction:
	var action_type: GameManager.Actions
	var args: Array
	var player_id: int
	var target_id: int

	func _init(target: int, type: GameManager.Actions, _args: Array = [], player: int = 1) -> void:
		action_type = type
		args = _args
		target_id = target
		player_id = player
