@tool
class_name DropZone
extends Node2D

@export var container: Node
@export var who_to_apply: Node = self
@export var shape: RectangleShape2D
@export var components: Array[Component]
@export var debug_color: Color
var global_rect: Rect2
var entity_id: int
var _world: World


func post_instantiate(world: World, id: int = -1, _spawn_data: Dictionary = {}) -> void:
	_world = world
	entity_id = id if id != -1 else world.create_entity()
	world.add_component(entity_id, CardNodeRef.new(self))
	for c: Resource in components:
		var comp = c.duplicate(true)
		world.add_component(entity_id, comp)


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
