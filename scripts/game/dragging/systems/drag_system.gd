class_name DragSystem
extends System


static func initialize():
	EventSystem.InscreverEventoLocal(
		DraggableComponent, CardInputEvent, Callable(DragSystem, "on_card_input")
	)


static func on_card_input(
	_entity: Entity, _comp: DraggableComponent, _args: CardInputEvent
) -> void:
	var node_comp = EntitySystem.get_comp(_entity, NodeComponent)
	if not node_comp or _comp.locked:
		return
	if _args.input_event.is_action_pressed("mouse_left"):
		on_drag_start(_comp, node_comp.node)
	if _args.input_event.is_action_released("mouse_left") and _comp.dragging:
		# Still iffy on how check_drop is checked and called.
		var dropzone = check_drop(node_comp.node)
		if dropzone:
			var ev = DropEvent.new(_entity, dropzone)
			EventSystem.IniciarEventoLocal(_entity, ev)

		on_drag_end(_comp, node_comp.node)


static func update(_delta: float) -> void:
	for entity in Entity.get_all_entities().values():
		var draggable = EntitySystem.get_comp(entity, DraggableComponent)
		if not draggable:
			continue
		var node_comp = EntitySystem.get_comp(entity, NodeComponent)
		if not node_comp:
			continue

		var node = node_comp.node

		# Se estiver sendo arrastado, move com o mouse
		if draggable.dragging:
			Globals.is_dragging = true
			node.global_position = node.get_global_mouse_position()
			if node.get_parent() is PlayerHand:
				node.get_parent().move_card(node)


static func lock_drag(
	comp: DraggableComponent,
	node: Node,
) -> void:
	comp.locked = true
	node.get_child(1).mouse_default_cursor_shape = Control.CURSOR_ARROW


static func unlock_drag(
	comp: DraggableComponent,
	node: Node,
) -> void:
	comp.locked = false
	node.get_child(1).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


static func on_drag_start(comp: DraggableComponent, node: Node) -> void:
	node.get_child(1).mouse_default_cursor_shape = Control.CURSOR_DRAG
	node.card_is_focused(true)
	comp.dragging = true
	Globals.is_dragging = true

	var xf: Transform2D = node.get_global_transform()
	var scale_x = xf.x.length()
	var rodtation = xf.x.angle()

	node.resize(comp.zoom / (scale_x / node.scale.x))
	node.rotate(0.1, node.rotation - rodtation)


static func on_drag_end(comp: DraggableComponent, node: Node) -> void:
	comp.dragging = false

	node.resize(1)
	node.get_child(1).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.rotate(.1, node.snap_rot)
	await node.move(.1, node.snap_pos)

	Globals.is_dragging = false
	node.card_is_focused(false)


static func check_drop(_card: Card) -> DropZone:
	var dropzone
	var drop_places := _card.get_tree().get_nodes_in_group("dropplace")
	var drop_area = _card.get_global_mouse_position()

	for drop_place in drop_places:
		if drop_place.global_rect.has_point(drop_place.to_local(drop_area)):
			dropzone = drop_place
			break
	if dropzone and dropzone is DropZone:
		return dropzone
	return null
