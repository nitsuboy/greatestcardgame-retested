class_name EffectSystem
extends System


static func apply(comp: ZoomableComponent, node: Node) -> void:
	node.card_is_focused(true)
	Globals.is_dragging = true

	var xf: Transform2D = node.get_global_transform()
	var scale_x = xf.x.length()
	var rodtation = xf.x.angle()
	var screen_center: Vector2 = DisplayServer.window_get_size() / 2
	var g_position: Vector2 = (xf.affine_inverse() * screen_center) - node.position

	node.resize(comp.zoom / (scale_x / node.scale.x))
	node.rotate(0.1, node.rotation - rodtation)
	node.move(0.1, g_position)


static func on_zoom_end(_comp: ZoomableComponent, node: Node) -> void:
	node.resize(1)
	await node.move(0.1, node.snap_pos, node.snap_rot)

	Globals.is_dragging = false
	node.card_is_focused(false)


static func handle_gui_input(entity: Entity, comp, args) -> void:
	pass
