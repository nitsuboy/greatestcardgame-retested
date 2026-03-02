class_name TriggerSystem
extends System


static func try_trigger(entity: Entity, comp: Component, args: EventArgs) -> void:
	Globals.trigger_queue += 1
	var comps = EntitySystem.get_comps(entity, Globals.on_trigger_components)
	for c in comps:
		if c.trigger_id == comp.trigger_id:
			match c.get_script():
				LogOnTriggerComponent:
					print(c.msg)
				DrawOnTriggerComponent:
					print("draw on trigger ativado")
					DrawSystem.draw_card_triggered(entity, c, args)
				DiscardOnTriggerComponent:
					print("discard on trigger ativado")
					DiscardCardSystem.discard_card_triggered(entity, c, args)
				_:
					push_warning("not in the action list")
	Globals.trigger_queue -= 1
	if Globals.trigger_queue == 0:
		print("corrente terminada")
