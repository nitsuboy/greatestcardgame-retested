@tool
class_name DropZone
extends Node2D

@export var container: Node
@export var who_to_apply: Node = self
@export var shape: RectangleShape2D
@export var components: Array[Component]
@export var debug_color: Color
var global_rect: Rect2
var entity: Entity


func post_instantiate(id: int = -1) -> void:
	if id == -1:
		id = EntityRegistry.calculate_next_entity_uid()
	EntityRegistry.add_new_entity_with_uid(id)
	entity = EntityRegistry.get_entity(id)

	EntitySystem.ensure_comp(entity, NodeComponent).node = self

	for c: Component in components:
		var comp = c.duplicate(true)
		if "hand" in comp:
			comp.hand = get_child(0)
			print(comp.hand)
			comp.debug = get_child(1)
		ComponentRegistry.add_component_to_entity(id, comp)


func _ready() -> void:
	global_rect = shape.get_rect()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_rect(Rect2(-shape.extents, shape.extents * 2), debug_color)
	else:
		if Globals.debug:
			draw_rect(Rect2(-shape.extents, shape.extents * 2), debug_color)


func add_card(node: Node) -> void:
	container.add_child(node)
