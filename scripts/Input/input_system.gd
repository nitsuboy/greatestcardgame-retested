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
