class_name DragSystem
extends System


static func update(_delta: float) -> void:
	for entity in Entity.get_all_entities():
		var draggable = EntitySystem.get_comp(entity, DraggableComponent)
		if not draggable:
			continue
		var node_comp = EntitySystem.get_comp(entity, NodeComponent)
		if not node_comp:
			continue

		var node = node_comp.node

		# Se estiver sendo arrastado, move com o mouse
		if draggable.dragging:
			node.global_position = node.get_global_mouse_position()
			if node.get_parent() is PlayerHand:
				node.get_parent().move_card(node)
			Globals.is_dragging = true


static func on_drag_start(comp: DraggableComponent, node: Node):
	node.get_child(1).mouse_default_cursor_shape = Control.CURSOR_DRAG
	node.card_is_focused(true)
	comp.dragging = true
	Globals.is_dragging = true

	var xf: Transform2D = node.get_global_transform()
	var scale_x = xf.x.length()
	var rodtation = xf.x.angle()

	node.resize(comp.zoom / (scale_x / node.scale.x))
	node.rotate(0.1, node.rotation - rodtation)


static func on_drag_end(comp: DraggableComponent, node: Node):
	comp.dragging = false

	node.resize(1)
	node.get_child(1).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	await node.move(0.1, node.snap_pos, node.snap_rot)

	Globals.is_dragging = false
	node.card_is_focused(false)


static func handle_gui_input(entity: Entity, comp: DraggableComponent, args: EventArgs) -> void:
	var node_comp = EntitySystem.get_comp(entity, NodeComponent)
	if not node_comp:
		return
	if args.input_event.is_action_pressed("mouse_left"):
		on_drag_start(comp, node_comp.node)
	if args.input_event.is_action_released("mouse_left"):
		on_drag_end(comp, node_comp.node)
