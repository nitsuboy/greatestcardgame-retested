@abstract class_name Event

var treated: bool = false
var args: EventArgs = null
var targets: Array[Entity] = []


func _init(event_args: EventArgs = null) -> void:
	args = event_args


@abstract func treat(_entity: Entity) -> void


func start() -> void:
	var entities_to_look: Array[Entity] = []

	if targets.is_empty():
		entities_to_look = Entity.get_all_entities()
	else:
		entities_to_look = targets

	for entity in entities_to_look:
		self.treat(entity)
