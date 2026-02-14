class_name DropZone
extends CollisionShape2D

@export var who_to_apply: Node
@export var comps: Component
var global_rect: Rect2
var entity: Entity

#TODO: fazer dropzones em entidades para tirar esse código duplicado


func _init() -> void:
	entity = Entity.new()
	var nc: NodeComponent = NodeComponent.new()
	nc.node = self
	entity.components.append(nc)
	entity.components.append(PlayZoneComponent.new())


func _ready():
	global_rect = shape.get_rect()
