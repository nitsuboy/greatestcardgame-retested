class_name CardInputEvent
extends Event


func _init(event_args: CardInputEventArgs = null) -> void:
	args = event_args
	targets = [event_args.entity]

func plantar()
	pass

func treat(_entity: Entity) -> void:
	var comp: Component

	comp = EntitySystem.get_comp(_entity, ZoomableComponent)

	comp = EntitySystem.get_comp(_entity, HoverbleComponent)
	if comp:
		HoverSystem.handle_gui_input(_entity, comp, args)

	if not args.input_event:
		return

	comp = EntitySystem.get_comp(_entity, ZoomableComponent)
	if comp:
		ZoomSystem.handle_gui_input(_entity, comp, args)

	comp = EntitySystem.get_comp(_entity, DraggableComponent)
	if comp:
		DragSystem.handle_gui_input(_entity, comp, args)
