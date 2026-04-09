class_name PreDrawCardEvent
extends Event


func _init(event_args: PreDrawCardEventArgs = null) -> void:
	args = event_args
	targets = []


func treat(_entity: Entity) -> void:
	var comp: Component

	comp = EntitySystem.get_comp(_entity, TriggerOnPreDrawComponent)
	if comp:
		TriggerSystem.try_trigger(_entity, comp, args)
