extends System
class_name DragSystem

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

static func _with_draggable_node(entity: Entity, func_ref: Callable) -> void:
	var draggable = EntitySystem.get_comp(entity, DraggableComponent)
	if not draggable:
		return
	var node_comp = EntitySystem.get_comp(entity, NodeComponent)
	if not node_comp:
		return
	
	func_ref.call(draggable, node_comp.node)

static func on_drag_start(entity: Entity):
	_with_draggable_node(entity, func(draggable, node):
		node.get_child(1).mouse_default_cursor_shape = Control.CURSOR_DRAG
		draggable.dragging = true
		Globals.is_dragging = true
		node.resize(1.2)
		node.rotate(0.1, node.rotation)
	)
	
static func on_drag_end(entity: Entity):
	_with_draggable_node(entity, func(draggable, node):
		node.get_child(1).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		draggable.dragging = false
		Globals.is_dragging = false
		node.move(0.1, node.snap_pos)
	)
	
