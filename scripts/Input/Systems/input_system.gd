class_name InputSystem extends System

static func handle_gui_input(card_input_event_args: CardInputEventArgs, node_comp: NodeComponent, entity: Entity) -> void:
	var card = node_comp.node
	
	var input_event = card_input_event_args.input_event

	if input_event:
		card.card_is_focused(true)
	else:
		card.card_is_focused(false) 
		return
	
	# Encaminhar eventos de input para os sistemas adequados
	
	var drag_comp = EntitySystem.get_comp(entity, DraggableComponent)
	if drag_comp:
		if input_event.is_action_pressed("mouse_left"):
			DragSystem.on_drag_start(entity)
		if input_event.is_action_released("mouse_left"):
			DragSystem.on_drag_end(entity)
	
	var zoom_comp = EntitySystem.get_comp(entity, ZoomableComponent)
	if zoom_comp:
		if input_event.is_action_pressed("mouse_left"):
			ZoomSystem.on_zoom_start(entity)
		if input_event.is_action_released("mouse_left"):
			ZoomSystem.on_zoom_end(entity)
