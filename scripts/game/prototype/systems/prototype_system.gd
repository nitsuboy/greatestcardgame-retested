class_name PrototypeSystem
extends System


static func initialize():
	EventSystem.inscrever_evento_local(
		SpawnPrototypeOnTriggerComponent, TriggerEvent, Callable(PrototypeSystem, "on_trigger")
	)


static func on_trigger(
	_entity: Entity, _comp: SpawnPrototypeOnTriggerComponent, _args: TriggerEvent
) -> void:
	if not _comp.keys_in.has(_args.key_out):
		return

	if _comp.prototype_id.is_empty():
		push_warning("SpawnPrototypeSystem: empty prototype_id on entity %d" % _entity.id)
		return

	var action = TriggerAction.new(
		0,
		GameManager.Actions.SPAWN_PROTOTYPE,
		[_comp.prototype_id, str(_comp.target_parent), _comp.spawn_data.duplicate()]
	)
	TriggerRegistry.enqueue_trigger_action(action)
	print(
		(
			"    [ENQUEUED] SPAWN_PROTOTYPE | ID: %s | Parent: %s"
			% [_comp.prototype_id, _comp.target_parent]
		)
	)
