class_name TriggerSystem
extends System


static func initialize():
	EventSystem.InscreverEventoLocal(
		TriggerOnDiscardedComponent, DiscardCardEvent, Callable(TriggerSystem, "try_trigger")
	)
	EventSystem.InscreverEventoLocal(
		TriggerOnPlayedComponent, PlayCardEvent, Callable(TriggerSystem, "try_trigger")
	)
	EventSystem.InscreverEventoLocal(
		TriggerOnDrawComponent, DrawCardEvent, Callable(TriggerSystem, "try_trigger")
	)
	EventSystem.InscreverEventoLocal(
		TriggerOnPreDrawComponent, PreDrawCardEvent, Callable(TriggerSystem, "try_trigger")
	)
	EventSystem.InscreverEventoLocal(
		TriggerOnOtherCardDrawComponent, DrawOtherCardEvent, Callable(TriggerSystem, "try_trigger")
	)

	EventSystem.InscreverEventoLocal(
		LogOnTriggerComponent, TriggerEvent, Callable(TriggerSystem, "on_trigger_log")
	)


# TODO: mover isso para um sistema de log
static func on_trigger_log(_entity: Entity, _comp: LogOnTriggerComponent, _args: TriggerEvent):
	if not _comp.keys_in.has(_args.key_out):
		return
	print("    [LOG] %s" % _comp.msg)


static func try_trigger(_entity: Entity, _comp: TriggerOnComponent, _args: Event) -> void:
	print("=== TriggerSystem: try_trigger ===")
	print("  Entity: %d | Comp key_out: %s" % [_entity.id, _comp.key_out])

	var ev = TriggerEvent.new(_comp.key_out)
	EventSystem.IniciarEventoLocal(_entity, ev)

	print("  Queue size: %d" % Net.get_trigger_queue_size())
	if not Net.is_trigger_queue_empty():
		print("  Actions queued:")
		var queue = Net.get_trigger_action_queue()
		for i in queue:
			print("    - %s | Args: %s" % [GameManager.Actions.keys()[i.action_type], str(i.args)])
	print("==============================")


class TriggerAction:
	var action_type: GameManager.Actions
	var args: Array
	var player_id: int
	var target_id: int

	func _init(target: int, type: GameManager.Actions, _args: Array = [], player: int = 1) -> void:
		action_type = type
		args = _args
		target_id = target
		player_id = player
