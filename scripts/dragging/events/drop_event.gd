class_name DropEvent
extends Event

func _init(event_args: DropEventArgs = null) -> void:
	args = event_args
	targets = [event_args.card_entity]
	
func treat(entity: Entity) -> void:
	var comp: Component
	
	comp = EntitySystem.get_comp(entity, PlayableComponent)
	if comp:
		PlayCardSystem.TryPlayCard(entity, comp, args)
