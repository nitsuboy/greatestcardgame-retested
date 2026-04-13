class_name DiscardCardEvent
extends Event


func _init(event_args: DiscardCardEventArgs = null) -> void:
	args = event_args
	targets = [event_args.card_entity]


func treat(_entity: Entity) -> void:
	var comp: Component

	comp = EntitySystem.get_comp(_entity, TriggerOnDiscardedComponent)
	if comp:
		TriggerSystem.try_trigger(_entity, comp, args)
