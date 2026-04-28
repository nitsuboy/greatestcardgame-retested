class_name TriggerSystem
extends System


static func initialize():
	EventSystem.inscrever_evento_local(
		TriggerOnDiscardedComponent, DiscardCardEvent, Callable(TriggerSystem, "try_trigger")
	)
	EventSystem.inscrever_evento_local(
		TriggerOnPlayedComponent, PlayCardEvent, Callable(TriggerSystem, "try_trigger")
	)
	EventSystem.inscrever_evento_local(
		TriggerOnDrawComponent, DrawCardEvent, Callable(TriggerSystem, "try_trigger")
	)
	EventSystem.inscrever_evento_local(
		TriggerOnPreDrawComponent, PreDrawCardEvent, Callable(TriggerSystem, "try_trigger")
	)
	EventSystem.inscrever_evento_local(
		TriggerOnOtherCardDrawComponent, DrawOtherCardEvent, Callable(TriggerSystem, "try_trigger")
	)

	EventSystem.inscrever_evento_local(
		LogOnTriggerComponent, TriggerEvent, Callable(TriggerSystem, "on_trigger_log")
	)
	
	EventSystem.inscrever_evento_local(
		CancelTriggerComponent, TryTriggerEvent, Callable(TriggerSystem, "on_try_trigger")
	)


# TODO: mover isso para um sistema de log
static func on_trigger_log(_entity: Entity, _comp: LogOnTriggerComponent, _args: TriggerEvent):
	if not _comp.keys_in.has(_args.key_out):
		return
	print("    [LOG] %s" % _comp.msg)


static func try_trigger(_entity: Entity, _comp: TriggerOnComponent, _args: Event) -> void:
	print("=== TriggerSystem: try_trigger ===")
	print("  Entity: %d | Comp key_out: %s" % [_entity.id, _comp.key_out])

	var try_ev = TryTriggerEvent.new()
	EventSystem.iniciar_evento_local(_entity, try_ev)
	
	if try_ev.canceled:
		return

	var ev = TriggerEvent.new(_comp.key_out)
	EventSystem.iniciar_evento_local(_entity, ev)

	print("  Queue size: %d" % Net.get_trigger_queue_size())
	if not Net.is_trigger_queue_empty():
		print("  Actions queued:")
		var queue = Net.get_trigger_action_queue()
		for i in queue:
			print("    - %s | Args: %s" % [GameManager.Actions.keys()[i.action_type], str(i.args)])
	print("==============================")


static func on_try_trigger(_entity: Entity, _comp: CancelTriggerComponent, _args: TryTriggerEvent):
	_args.canceled = true


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
