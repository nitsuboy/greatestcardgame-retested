class_name HoverSystemOld
extends System


static func initialize():
	EventSystem.inscrever_evento_local(
		HoverableComponent, CardInputEvent, Callable(HoverSystem, "on_card_input")
	)


static func on_card_input(
	_entity: Entity, _comp: HoverableComponent, _args: CardInputEvent
) -> void:
	var node_comp = EntitySystem.get_comp(_entity, NodeComponent)
	if not node_comp:
		return
	if Globals.is_dragging:
		return
	if _args.input_event:
		on_hover_start(_comp, node_comp.node)
	elif not _args.input_event:
		on_hover_end(_comp, node_comp.node)


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
