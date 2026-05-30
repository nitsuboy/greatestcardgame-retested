## Hover system (visual focus on mouse over).
##
## When the mouse enters/exits a card, applies zoom and visual focus.
## Ignores hover during drag to avoid interference.
class_name HoverSystem
extends SystemNode


func init_system() -> void:
	world.events.on_card_mouse_exited.connect(_on_card_mouse_exited)
	world.events.on_card_mouse_entered.connect(_on_card_mouse_entered)


func _on_card_mouse_entered(entity_id: int) -> void:
	if (
		not world.has_component(entity_id, HoverableComponent)
		or (world.get_storage(DragState) != null and world.get_storage(DragState).size() > 0)
	):
		return

	_on_hover_start(entity_id)


func _on_card_mouse_exited(entity_id: int) -> void:
	if (
		not world.has_component(entity_id, HoverableComponent)
		or (world.get_storage(DragState) != null and world.get_storage(DragState).size() > 0)
	):
		return
	_on_hover_end(entity_id)


func _on_hover_start(entity_id: int) -> void:
	var comp: HoverableComponent = world.get_component(entity_id, HoverableComponent)
	if comp.locked:
		return
	var ref: NodeRef = world.get_component(entity_id, NodeRef)
	if not ref:
		return
	ref.node.card_is_focused(true)
	ref.node.resize(comp.zoom)


func _on_hover_end(entity_id: int) -> void:
	if not world.has_component(entity_id, HoverableComponent):
		return
	var ref: NodeRef = world.get_component(entity_id, NodeRef)
	if not ref:
		return
	ref.node.resize(1)
	ref.node.card_is_focused(false)
