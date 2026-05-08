class_name TriggerRegistry
extends RefCounted

static var _trigger_action_queue: Array[TriggerAction] = []


static func enqueue_trigger_action(action: TriggerAction) -> void:
	_trigger_action_queue.append(action)


static func modify_front_trigger_action(args) -> void:
	_trigger_action_queue[_trigger_action_queue.size() - 1].args = args


static func has_trigger_actions() -> bool:
	return not _trigger_action_queue.is_empty()


static func get_next_trigger_action() -> TriggerAction:
	if _trigger_action_queue.is_empty():
		return null
	return _trigger_action_queue.pop_back()


static func get_trigger_action_queue() -> Array[TriggerAction]:
	return _trigger_action_queue


static func get_trigger_queue_size() -> int:
	return _trigger_action_queue.size()


static func is_trigger_queue_empty() -> bool:
	return _trigger_action_queue.is_empty()
