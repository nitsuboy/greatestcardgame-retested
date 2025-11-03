class_name ZoomSystem
extends System


static func on_zoom_start(comp: ZoomableComponent, node: Node) -> void:
	Globals.is_dragging = true
	node.get_child(1).mouse_default_cursor_shape = Control.CURSOR_HELP
	var xf: Transform2D = node.get_global_transform()
	var scale_x = xf.x.length()
	var rodtation = xf.x.angle()
	node.resize(comp.zoom / (scale_x / node.scale.x))
	node.rotate(0.1, node.rotation - rodtation)
	var disp_size: Vector2 = DisplayServer.window_get_size() / 2
	var g_position: Vector2 = disp_size - node.global_position
	node.move(0.1, g_position)


static func on_zoom_end(_comp: ZoomableComponent, node: Node) -> void:
	Globals.is_dragging = false
	node.get_child(1).mouse_default_cursor_shape = Control.CURSOR_HELP
	node.card_is_focused(false)
	node.move(0.1, node.snap_pos, node.snap_rot)


static func handle_gui_input(entity: Entity, comp, args) -> void:
	var node_comp = EntitySystem.get_comp(entity, NodeComponent)
	if not node_comp:
		return
	if args.input_event.is_action_pressed("mouse_left"):
		on_zoom_start(comp, node_comp.node)
	if args.input_event.is_action_released("mouse_left"):
		on_zoom_end(comp, node_comp.node)
