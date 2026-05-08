class_name ZoomSystem
extends SystemNode


func init_system() -> void:
	world.events.on_card_input.connect(_on_card_input)


func _on_card_input(entity_id: int, event: InputEvent) -> void:
	if not world.has_component(entity_id, ZoomableComponent):
		return
	var comp: ZoomableComponent = world.get_component(entity_id, ZoomableComponent)

	if event.is_action_pressed("mouse_left"):
		_on_zoom_start(entity_id)
	elif event.is_action_released("mouse_left") and world.has_component(entity_id, DragState):
		_on_zoom_end(entity_id)


func _on_zoom_start(entity_id: int) -> void:
	var comp: ZoomableComponent = world.get_component(entity_id, ZoomableComponent)
	var ref: CardNodeRef = world.get_component(entity_id, CardNodeRef)
	world.add_component(entity_id, DragState.new())

	ref.node.get_child(1).mouse_default_cursor_shape = Control.CURSOR_DRAG
	ref.node.card_is_focused(true)

	var xf: Transform2D = ref.node.get_global_transform()
	var scale_x = xf.x.length()
	var rodtation = xf.x.angle()
	var screen_center: Vector2 = DisplayServer.window_get_size() / 2.
	var g_position: Vector2 = (xf.affine_inverse() * screen_center) + ref.node.position

	ref.node.resize(comp.zoom / (scale_x / ref.node.scale.x))
	ref.node.rotate(0.1, ref.node.rotation - rodtation)
	ref.node.move(0.1, g_position)


func _on_zoom_end(entity_id) -> void:
	var ref: CardNodeRef = world.get_component(entity_id, CardNodeRef)
	world.remove_component(entity_id, DragState)

	ref.node.resize(1)
	ref.node.get_child(1).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	ref.node.rotate(.1, ref.node.snap_rot)
	await ref.node.move(.1, ref.node.snap_pos)
	ref.node.card_is_focused(false)
