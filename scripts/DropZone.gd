extends CollisionShape2D
class_name DropZone

@export var who_to_apply: Node
var global_rect: Rect2


func _ready():
	global_rect = shape.get_rect()
