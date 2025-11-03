class_name InputSystem extends System


func _on_gui_input(event: InputEvent) -> void:
	# MOUSE

	if event.is_action_pressed("mouse_left"):
		var mouse_event = event as InputEventMouseButton
		var ev_args = MouseClickEventArgs.new(mouse_event.position)
		var left_click_event = MouseLeftClickEvent.new(ev_args)
		left_click_event.start()
		return

	if event.is_action_pressed("mouse_right"):
		var mouse_event = event as InputEventMouseButton
		var ev_args = MouseClickEventArgs.new(mouse_event.position)
		var left_click_event = MouseRightClickEvent.new(ev_args)
		left_click_event.start()
		return

static func handle_gui_input(event: InputEvent, entity: Entity) -> void:
	var node_comp = EntitySystem.get_comp(entity, NodeComponent)
	if not node_comp:
		return
	
	var card = node_comp.node

	if event :
		card.card_is_focused(true)
	else:
		card.card_is_focused(false) 
		return

	# Encaminhar eventos de input para os sistemas adequados
	if event.is_action_pressed("mouse_left"):
		DragSystem.on_drag_start(entity)
		ZoomSystem.on_zoom_start(entity)
	elif event.is_action_released("mouse_left"):
		DragSystem.on_drag_end(entity)
		ZoomSystem.on_zoom_end(entity)