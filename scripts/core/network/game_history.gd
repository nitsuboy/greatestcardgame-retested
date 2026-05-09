class_name GameHistory
extends RefCounted

var entries: Array[Dictionary] = []


func record(
	action: String, sender_id: int, data: Dictionary, result_batch: Array[Dictionary]
) -> void:
	entries.append(
		{
			"seq": entries.size(),
			"action": action,
			"sender": sender_id,
			"input": data.duplicate(),
			"result": result_batch.duplicate(),
			"timestamp": Time.get_unix_time_from_system()
		}
	)


func get_last() -> Dictionary:
	return entries.back() if entries else {}


func clear() -> void:
	entries.clear()
