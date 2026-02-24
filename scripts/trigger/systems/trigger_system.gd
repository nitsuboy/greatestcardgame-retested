class_name TriggerSystem
extends System

static func try_trigger(entity: Entity, comp: Component, args:EventArgs) -> void:
	var comps = EntitySystem.get_comps(entity, Globals.on_trigger_components)
	for c in comps:
		if c.trigger_id == comp.trigger_id:
			match comp.get_script():
				DrawOnTriggerComponent:
					DrawSystem.request_draw(entity,comp,args)
				_:
					push_warning("not in the action list")
