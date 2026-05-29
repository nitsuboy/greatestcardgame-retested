## Card interaction system (drag and zoom).
##
## Detects card clicks via EventBus and decides whether to start a drag
## (DraggableComponent) or zoom (ZoomableComponent). Uses duck-typing
## to call game methods without coupling.
class_name InteractionSystem
extends SystemNode

var _game_entity: int = -1


func init_system() -> void:
	world.events.on_game_entity_ready.connect(func(e): _game_entity = e)
	world.events.on_card_input.connect(_on_card_input)


func update(_delta: float) -> void:
	world.query([DragState, NodeRef]).for_each(
		func(e, comps):
			if not world.has_component(e, DraggableComponent):
				return
			var ref: NodeRef = comps[1]
			ref.node.global_position = ref.node.get_global_mouse_position()
			var parent = ref.node.get_parent()
			if parent and parent.has_method("move_card"):
				parent.move_card(ref.node)
	)


func _on_card_input(entity_id: int, event: InputEvent) -> void:
	var comp: Component = null

	for assure in [DraggableComponent, ZoomableComponent]:
		if world.has_component(entity_id, assure):
			comp = world.get_component(entity_id, assure)
			break

	if not comp:
		return

	if event.is_action_pressed("mouse_left"):
		if comp.locked:
			return
		_start(entity_id, comp)
	elif event.is_action_released("mouse_left") and world.has_component(entity_id, DragState):
		_end(entity_id, comp is DraggableComponent)


func _start(entity_id: int, comp: Component) -> void:
	var ref: NodeRef = world.get_component(entity_id, NodeRef)
	world.add_component(entity_id, DragState.new())

	ref.node.get_child(1).mouse_default_cursor_shape = Control.CURSOR_DRAG
	ref.node.card_is_focused(true)

	var xf: Transform2D = ref.node.get_global_transform()
	ref.node.resize(comp.zoom / (xf.x.length() / ref.node.scale.x))
	ref.node.rotate(0.1, ref.node.rotation - xf.x.angle())

	if comp is ZoomableComponent:
		_zoom_to_center(ref, xf)


func _zoom_to_center(ref: NodeRef, xf: Transform2D) -> void:
	var screen_center = DisplayServer.window_get_size() / 2.0
	var g_position = (xf.affine_inverse() * screen_center) + ref.node.position
	ref.node.move(0.1, g_position)


func _end(entity_id: int, is_draggable: bool) -> void:
	var ref: NodeRef = world.get_component(entity_id, NodeRef)
	world.remove_component(entity_id, DragState)

	ref.node.resize(1)
	ref.node.get_child(1).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	ref.node.rotate(.1, ref.node.snap_rot)

	if is_draggable:
		ref.node.move(.1, ref.node.snap_pos)
		ref.node.card_is_focused(false)
		var dropzone := _check_drop(ref.node)
		if dropzone:
			world.events.on_card_dropped.emit(entity_id, dropzone)
	else:
		await ref.node.move(.1, ref.node.snap_pos)
		ref.node.card_is_focused(false)


func _check_drop(card: Node) -> DropZone:
	for drop_place in card.get_tree().get_nodes_in_group("dropplace"):
		if drop_place.global_rect.has_point(drop_place.to_local(card.get_global_mouse_position())):
			if drop_place is DropZone:
				return drop_place
	return null
