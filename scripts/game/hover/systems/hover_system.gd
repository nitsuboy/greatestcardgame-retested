class_name HoverSystem
extends SystemNode


func init_system() -> void:
	world.events.on_card_input.connect(_on_card_input)
	world.events.on_card_mouse_exited.connect(_on_card_mouse_exited)


func _on_card_input(entity_id: int, _event: InputEvent) -> void:
	if not world.has_component(entity_id, HoverableComponent):
		return
	if world.has_component(entity_id, DragState):
		return
	_on_hover_start(entity_id)


func _on_card_mouse_exited(entity_id: int) -> void:
	_on_hover_end(entity_id)


func _on_hover_start(entity_id: int) -> void:
	var comp: HoverableComponent = world.get_component(entity_id, HoverableComponent)
	if comp.locked:
		return
	var ref: CardNodeRef = world.get_component(entity_id, CardNodeRef)
	if not ref:
		return
	ref.node.card_is_focused(true)
	ref.node.resize(comp.zoom)


func _on_hover_end(entity_id: int) -> void:
	if not world.has_component(entity_id, HoverableComponent):
		return
	var ref: CardNodeRef = world.get_component(entity_id, CardNodeRef)
	if not ref:
		return
	ref.node.card_is_focused(false)
	ref.node.resize(1)
