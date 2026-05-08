# game_new/dragging/systems/drag_system.gd
class_name DragSystem
extends SystemNode


func init_system() -> void:
	world.events.on_card_input.connect(_on_card_input)


func _ecs_update(_delta: float) -> void:
	world.query([DragState, CardNodeRef, DraggableComponent]).for_each(
		func(_entity_id, comps):
			var ref: CardNodeRef = comps[1]
			ref.node.global_position = ref.node.get_global_mouse_position()
			if ref.node.get_parent() is PlayerHand:
				ref.node.get_parent().move_card(ref.node)
	)


func _on_card_input(entity_id: int, event: InputEvent) -> void:
	if not world.has_component(entity_id, DraggableComponent):
		return
	var comp: DraggableComponent = world.get_component(entity_id, DraggableComponent)
	if comp.locked:
		return

	if event.is_action_pressed("mouse_left"):
		_on_drag_start(entity_id)
	elif event.is_action_released("mouse_left") and world.has_component(entity_id, DragState):
		_on_drag_end(entity_id)


func _on_drag_start(entity_id: int) -> void:
	var comp: DraggableComponent = world.get_component(entity_id, DraggableComponent)
	var ref: CardNodeRef = world.get_component(entity_id, CardNodeRef)
	world.add_component(entity_id, DragState.new())

	ref.node.get_child(1).mouse_default_cursor_shape = Control.CURSOR_DRAG
	ref.node.card_is_focused(true)

	var xf: Transform2D = ref.node.get_global_transform()
	ref.node.resize(comp.zoom / (xf.x.length() / ref.node.scale.x))
	ref.node.rotate(0.1, ref.node.rotation - xf.x.angle())


func _on_drag_end(entity_id: int) -> void:
	var ref: CardNodeRef = world.get_component(entity_id, CardNodeRef)
	world.remove_component(entity_id, DragState)

	ref.node.resize(1)
	ref.node.get_child(1).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	ref.node.rotate(.1, ref.node.snap_rot)
	ref.node.move(.1, ref.node.snap_pos)
	ref.node.card_is_focused(false)

	# drop check
	var dropzone = _check_drop(ref.node)
	if dropzone:
		world.events.on_card_dropped.emit(entity_id, dropzone)


func _check_drop(card: Card) -> DropZone:
	for drop_place in card.get_tree().get_nodes_in_group("dropplace"):
		if drop_place.global_rect.has_point(drop_place.to_local(card.get_global_mouse_position())):
			if drop_place is DropZone:
				return drop_place
	return null
