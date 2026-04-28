class_name CardInputEvent
extends Event


func _init(event_args: CardInputEventArgs = null) -> void:
	args = event_args
	targets = [event_args.entity]


func treat(_entity: Entity) -> void:
	var comp: Component

	comp = EntitySystem.get_comp(_entity, HoverableComponent)
	if comp:
		HoverSystem.handle_gui_input(_entity, comp, args)

	if not args.input_event:
		return

