class_name HoverSystem
extends System


static func on_hover_start(comp: HoverableComponent, node: Node) -> void:
	if comp.locked:
		return
	node.card_is_focused(true)
	node.resize(comp.zoom)


static func on_hover_end(comp: HoverableComponent, node: Node) -> void:
	if comp.locked:
		node.card_is_focused(false)
		node.resize(1)
		return
	node.card_is_focused(false)
	node.resize(1)


static func lock_hover(comp: HoverableComponent) -> void:
	comp.locked = true


static func unlock_hover(comp: HoverableComponent) -> void:
	comp.locked = false


static func handle_gui_input(entity: Entity, comp, args) -> void:
	var node_comp = EntitySystem.get_comp(entity, NodeComponent)
	if not node_comp:
		return
	if Globals.is_dragging:
		return
	if args.input_event:
		on_hover_start(comp, node_comp.node)
	elif not args.input_event:
		on_hover_end(comp, node_comp.node)
