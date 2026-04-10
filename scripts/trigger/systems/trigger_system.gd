class_name TriggerSystem
extends System

class TriggerAction:
	var action_type: GameManager.Actions
	var args: Array
	
	func _init(type: GameManager.Actions, _args: Array) -> void:
		action_type = type
		args = _args

static func try_trigger(entity: Entity, comp: TriggerOnComponent, _args: EventArgs) -> void:
	var on_trigger_comps = EntitySystem.get_comps_related(entity, OnTriggerComponent)
	for on_trigger_comp: OnTriggerComponent in on_trigger_comps:
		if on_trigger_comp.keys_in.has(comp.key_out):
			match on_trigger_comp.get_script():
				LogOnTriggerComponent:
					print((on_trigger_comp as LogOnTriggerComponent).msg)
				DrawOnTriggerComponent:
					var draw_comp = on_trigger_comp as DrawOnTriggerComponent
					var action = TriggerAction.new(GameManager.Actions.DRAW_CARD, [draw_comp.number_of_cards, draw_comp.player])
					NetworkManager.enqueue_trigger_action(action)
				SkipTurnOnTriggerComponent:
					var skip_comp = on_trigger_comp as SkipTurnOnTriggerComponent
					var action = TriggerAction.new(GameManager.Actions.SKIP_TURN, [skip_comp.num_of_turns])
					NetworkManager.enqueue_trigger_action(action)
				DiscardOnTriggerComponent:
					var action = TriggerAction.new(GameManager.Actions.DISCARD_CARD, [entity.id])
					NetworkManager.enqueue_trigger_action(action)
				_:
					push_warning("not in the action list")
	print("=====")
	for i in NetworkManager._trigger_action_queue:
		print(GameManager.Actions.keys()[i.action_type])
	print("=====")
