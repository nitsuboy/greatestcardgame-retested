class_name CardInputEvent
extends Event

func init(event_args : CardInputEventArgs = null) -> void:
	args = event_args
	targets = [event_args.entity]

func treat(_entity: Entity) -> void:
	var comp : Component

	comp = EntitySystem.get_comp(_entity, NodeComponent)
	if comp:
		InputSystem.handle_gui_input(args, comp, _entity)
