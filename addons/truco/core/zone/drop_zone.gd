## Drop zone for cards in the scene tree.
##
## Defines a rectangular area where cards can be dropped.
## Automatically registers with ZoneRegistry when entering the tree.
## Each zone has a unique zone_id and a container for cards.
@tool
class_name DropZone
extends Node2D

## Container where cards will be added as children.
@export var container: Node
## Rectangular shape of the drop area.
@export var shape: RectangleShape2D
## Components to add to this zone's entity.
@export var components: Array[Component]
## Enables debug visualization of the area.
@export var debug: bool = false
## Debug visualization color.
@export var debug_color: Color
## Unique ID of this zone in ZoneRegistry.
@export var zone_id: int = 0

## Global rect calculated from the shape.
var global_rect: Rect2
## ECS entity ID associated with this zone.
var entity_id: int
var _world: World


## Links this zone to an ECS entity and adds components.
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


## Adds a card visual to this zone's container.
func add_card(node: Node) -> void:
	container.add_child(node)
