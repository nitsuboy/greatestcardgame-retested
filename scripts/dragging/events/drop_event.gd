class_name DropEvent
extends Event


func _init(event_args: DropEventArgs = null) -> void:
	args = event_args
	targets = [event_args.card_entity]


func treat(_entity: Entity) -> void:
	var comp: Component

	comp = EntitySystem.get_comp(_entity, PlayableComponent)
	if comp:
		PlayCardSystem.try_play_card(_entity, comp, args)

	comp = EntitySystem.get_comp(_entity, DiscardableComponent)
	if comp:
		DiscardCardSystem.try_discard_card(_entity, comp, args)
