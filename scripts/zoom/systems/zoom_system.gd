class_name ZoomSystem
extends System

static func _with_zoomable_node(entity: Entity, func_ref: Callable) -> void:
	var zoomable = EntitySystem.get_comp(entity, ZoomableComponent)
	if not zoomable:
		return
	var node_comp = EntitySystem.get_comp(entity, NodeComponent)
	if not node_comp:
		return
	
	func_ref.call(zoomable, node_comp.node)

static func on_zoom_start(entity:Entity) -> void:
	_with_zoomable_node(entity, func(draggable, node):
		Globals.is_dragging = true
		node.get_child(1).mouse_default_cursor_shape = Control.CURSOR_HELP
		var xf: Transform2D = node.get_global_transform()
		var scale_x = xf.x.length()
		var rodtation = xf.x.angle()
		node.resize(1.5 / (scale_x / node.scale.x))
		node.rotate(0.1, node.rotation - rodtation)
		var disp_size: Vector2 = DisplayServer.window_get_size() / 2
		var g_position: Vector2 = disp_size - node.global_position
		node.move(0.1, g_position)
	)

static func on_zoom_end(entity:Entity) -> void:
	_with_zoomable_node(entity, func(draggable, node):
		Globals.is_dragging = false
		node.get_child(1).mouse_default_cursor_shape = Control.CURSOR_HELP
		node.card_is_focused(false)
		node.move(0.1, node.snap_pos, node.snap_rot)
	)
