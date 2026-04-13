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
	entity = Entity.new(id)
	var nc: NodeComponent = NodeComponent.new()
	nc.node = self
	entity.components.append(nc)

	for c: Component in components:
		var comp = c.duplicate(true)
		if "hand" in comp:
			comp.hand = get_child(0)
			comp.debug = get_child(1)
		entity.components.append(comp)


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
