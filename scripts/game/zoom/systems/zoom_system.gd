class_name ZoomSystem
extends System


static func initialize():
	EventSystem.inscrever_evento_local(
		ZoomableComponent, CardInputEvent, Callable(ZoomSystem, "on_card_input")
	)


static func on_card_input(_entity: Entity, _comp: ZoomableComponent, _args: CardInputEvent) -> void:
	var node_comp = EntitySystem.get_comp(_entity, NodeComponent)
	if not node_comp:
		return
	if _args.input_event.is_action_pressed("mouse_left"):
		on_zoom_start(_comp, node_comp.node)
	if _args.input_event.is_action_released("mouse_left"):
		on_zoom_end(_comp, node_comp.node)


static func on_zoom_start(comp: ZoomableComponent, node: Node) -> void:
	node.card_is_focused(true)
	Globals.is_dragging = true

	var xf: Transform2D = node.get_global_transform()
	var scale_x = xf.x.length()
	var rodtation = xf.x.angle()
	var screen_center: Vector2 = DisplayServer.window_get_size() / 2
	var g_position: Vector2 = (xf.affine_inverse() * screen_center) + node.position

	node.resize(comp.zoom / (scale_x / node.scale.x))
	node.rotate(0.1, node.rotation - rodtation)
	node.move(0.1, g_position)


static func on_zoom_end(_comp: ZoomableComponent, node: Node) -> void:
	node.resize(1)
	node.rotate(.1, node.snap_rot)
	await node.move(.1, node.snap_pos)

	Globals.is_dragging = false
	node.card_is_focused(false)
