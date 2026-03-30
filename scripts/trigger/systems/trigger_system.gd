class_name TriggerSystem
extends System


static func try_trigger(entity: Entity, comp: TriggerOnComponent, args: EventArgs) -> void:
	Globals.trigger_queue += 1
	var on_trigger_comps = EntitySystem.get_comps_related(entity, OnTriggerComponent)
	for on_trigger_comp in on_trigger_comps:
		on_trigger_comp = on_trigger_comp as OnTriggerComponent
		if on_trigger_comp.keys_in.has(comp.key_out):
			match on_trigger_comp.get_script():
				LogOnTriggerComponent:
					var log_on_trigger_comp = on_trigger_comp as LogOnTriggerComponent
					print(log_on_trigger_comp.msg)
				DrawOnTriggerComponent:
					var draw_on_trigger_comp = on_trigger_comp as DrawOnTriggerComponent
					DrawSystem.draw_card_request(entity, draw_on_trigger_comp, args)
				DiscardOnTriggerComponent:
					DiscardCardSystem.discard_card_request(entity)
				_:
					push_warning("not in the action list")
	Globals.trigger_queue -= 1
	if Globals.trigger_queue == 0:
		print("end of chain")
