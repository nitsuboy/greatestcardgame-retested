## Drop zone for cards in the scene tree.
##
## Defines a rectangular area where cards can be dropped.
## Automatically registers with ZoneRegistry when entering the tree.
## Each zone has a unique zone_id and a container for cards.
@tool
class_name DropZone3D
extends Node3D

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
@export var jitter_x: float = 0
@export var jitter_y: float = 0
@export var jitter_spin: float = 0
@export var incremente_altura: bool

## Global rect calculated from the shape.
var global_rect: Rect2
## ECS entity ID associated with this zone.
var entity_id: int
var altura: float = 0
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
		_update_preview()
		return
	Zones.register(zone_id, self)


func _update_preview() -> void:
	var card: Node3D
	card = MeshInstance3D.new()
	card.mesh = BoxMesh.new()
	card.mesh.size = Vector3(1.5, .1, 1.5)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = debug_color
	card.mesh.surface_set_material(0, mat)
	add_child(card)


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	Zones.unregister(zone_id)


## Adds a card visual to this zone's container.
func add_card(card: Node3D) -> void:
	if container:
		container.add_card(card)
		return
	var start = Vector3.ZERO
	if card.get_parent():
		start = card.global_position
		card.get_parent().remove_child(card)
	var target := global_position + (Vector3.UP * altura)
	if incremente_altura:
		altura += 0.01

	# aleatoriedade na posição final (pra não empilhar perfeito)
	var jitter := Vector3(randf_range(-jitter_x, jitter_x), 0.0, randf_range(-jitter_y, jitter_y))

	# aleatoriedade no giro final (pequena inclinação)
	var spin := randf_range(-jitter_spin, jitter_spin)  # rotação Y ao cair
	if card.get_parent():
		card.get_parent().remove_child(card)

	add_child(card)
	card.global_position = start

	var tw := create_tween().set_parallel(true)

	# arco no eixo Y + posição final com jitter
	(
		tw
		. tween_method(_arc_tween.bind(card, start, target + jitter), 0.0, 1.0, 0.35)
		. set_trans(Tween.TRANS_QUAD)
		. set_ease(Tween.EASE_IN_OUT)
	)

	# rotação: cai girando e termina com tilt
	tw.tween_property(card, "rotation:y", spin, 0.35).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(card, "rotation:z", 0, 0.25).set_delay(0.1).set_trans(Tween.TRANS_BACK)


func _arc_tween(progress: float, card: Node3D, start: Vector3, target: Vector3) -> void:
	var base := start.lerp(target, progress)
	var height := sin(progress * PI) * 0.4  # arco de 40cm
	card.global_position = base + Vector3(0, height, 0)
