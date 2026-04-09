class_name DrawCardEvent
extends Event


func _init(event_args: DrawCardEventArgs = null) -> void:
	args = event_args
	targets = [event_args.card_entity]


func treat(_entity: Entity) -> void:
	var comp: Component

	comp = EntitySystem.get_comp(_entity, TriggerOnDrawComponent)
	if comp:
		TriggerSystem.try_trigger(_entity, comp, args)
