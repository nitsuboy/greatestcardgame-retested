class_name CardGuiInputEvent
extends Event

func _init(event_args: InputEvent, target_entity: Entity):
	args = event_args
	targets = [target_entity]

func treat(entity: Entity) -> void:
	var comp : Component

	comp = EntitySystem.get_comp(entity, NodeComponent)
	if comp:
		InputSystem.handle_gui_input(args, node_comp, entity)
