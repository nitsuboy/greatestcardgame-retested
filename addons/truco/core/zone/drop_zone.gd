@tool
class_name DropZone
extends Node2D

@export var container: Node
@export var shape: RectangleShape2D
@export var components: Array[Component]
@export var debug: bool = false
@export var debug_color: Color
@export var zone_id: int = 0

var global_rect: Rect2
var entity_id: int
var _world: World


func post_instantiate(world: World, id: int = -1, _spawn_data: Dictionary = {}) -> void:
	_world = world
	entity_id = id if id != -1 else world.create_entity()
	world.add_component(entity_id, NodeRef.new(self))
	for c: Component in components:
		var comp = c.duplicate(true)
		world.add_component(entity_id, comp)


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	global_rect = shape.get_rect()
	Zones.register(zone_id, self)


func _exit_tree() -> void:
	Zones.unregister(zone_id)


func _draw() -> void:
	if Engine.is_editor_hint() or debug:
		draw_rect(Rect2(-shape.extents, shape.extents * 2), debug_color)


func add_card(node: Node) -> void:
	container.add_child(node)
