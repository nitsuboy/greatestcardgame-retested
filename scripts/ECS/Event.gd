@abstract
class_name Event

var treated : bool = false
var args : Event_Args = null
var targets : Array[Entity] = []

func _init(eventArgs : Event_Args = null) -> void:
	args = eventArgs

@abstract func treat(entity : Entity, component : Component) -> void

func start() -> void:
	var entities_to_look : Array[Entity] = []

	if targets.is_empty():
		entities_to_look = Entity.get_all_entities()
	else:
		entities_to_look = targets

	for entity in entities_to_look:
		for component in entity.components:
			self.treat(entity, component)

@abstract class Event_Args:
	pass
