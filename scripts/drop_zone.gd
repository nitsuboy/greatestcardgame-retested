@tool
class_name DropZone
extends Node2D

@export var static_container: VStaticContainer
@export var who_to_apply: Node = self
@export var shape: RectangleShape2D
@export var components: Array[Component]
@export var debug_color: Color
var global_rect: Rect2
var entity: Entity

#TODO: fazer dropzones em entidades para tirar esse código duplicado


func _init() -> void:
	entity = Entity.new()
	var nc: NodeComponent = NodeComponent.new()
	nc.node = self
	entity.components.append(nc)


func _ready():
	global_rect = shape.get_rect()

	for c: Component in components:
		entity.components.append(c.duplicate())
		if "cursor" in c:
			get_child(1).mouse_default_cursor_shape = c.cursor_shape


func _process(_delta: float) -> void:
	queue_redraw()


func _draw():
	if Engine.is_editor_hint():
		draw_rect(Rect2(-shape.extents, shape.extents * 2), debug_color)
	else:
		if Globals.debug:
			draw_rect(Rect2(-shape.extents, shape.extents * 2), debug_color)


func add_card(node: Node) -> void:
	static_container.add_child(node)
