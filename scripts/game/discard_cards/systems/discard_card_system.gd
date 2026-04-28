class_name DiscardCardSystem
extends System
	
static func initialize():
	EventSystem.InscreverEventoLocal(DiscardOnTriggerComponent, TriggerEvent, Callable(DiscardCardSystem, "on_trigger"))

static func on_trigger(entity: Entity, _comp: DiscardOnTriggerComponent, _args: TriggerEvent):
	if not _comp.keys_in.has(_args.key_out):
		return
	var action = TriggerSystem.TriggerAction.new(
		Net.multiplayer.get_unique_id(),
		GameManager.Actions.DISCARD_CARD,
		[entity.id]
	)
	Net.enqueue_trigger_action(action)
	print("    [ENQUEUED] DISCARD_CARD | Entity: %d" % entity.id)

static func discard_card(entity: Entity, _comp: NodeComponent) -> void:
	var game = Net.game
	var dealer = game.get_dealer()
	dealer.discard_card(_comp.node)

	if game.is_server():
		var ev = DiscardCardEvent.new(entity)
		EventSystem.IniciarEventoLocal(entity, ev)
