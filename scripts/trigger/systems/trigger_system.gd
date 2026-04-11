class_name TriggerSystem
extends System


static func try_trigger(entity: Entity, comp: TriggerOnComponent, _args: EventArgs) -> void:
	Globals.trigger_queue += 1
	var on_trigger_comps = EntitySystem.get_comps_related(entity, OnTriggerComponent)
	for on_trigger_comp: OnTriggerComponent in on_trigger_comps:
		if on_trigger_comp.keys_in.has(comp.key_out):
			match on_trigger_comp.get_script():
				LogOnTriggerComponent:
					var log_on_trigger_comp = on_trigger_comp as LogOnTriggerComponent
					print(log_on_trigger_comp.msg)
				DrawOnTriggerComponent:
					var draw_on_trigger_comp = on_trigger_comp as DrawOnTriggerComponent
					DrawCardSystem.draw_card_request(entity, draw_on_trigger_comp)
				DiscardOnTriggerComponent:
					DiscardCardSystem.discard_card_request(entity)
				SkipTurnOnTriggerComponent:
					var skip_turn_on_trigger_component = (
						on_trigger_comp as SkipTurnOnTriggerComponent
					)
					TurnSystem.change_turn_request(skip_turn_on_trigger_component.num_of_turns)
				_:
					push_warning("not in the action list")
	Globals.trigger_queue -= 1
	if Globals.trigger_queue == 0:
		print("end of chain")
