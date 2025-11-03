class_name CardInputEvent
extends Event

func init(event_args : CardInputEventArgs = null) -> void:
	args = event_args
	targets = [event_args.entity]

func treat(_entity: Entity) -> void:
	var comp : Component

	comp = EntitySystem.get_comp(_entity, DraggableComponent)
	if comp:
		DragSystem.handle_gui_input(_entity, comp, args)
		
	comp = EntitySystem.get_comp(_entity, ZoomableComponent)
	if comp:
		ZoomSystem.handle_gui_input(_entity, comp, args)
