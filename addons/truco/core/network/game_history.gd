## Record of game action history.
##
## Stores a sequence of actions with timestamps, input data,
## and resulting batches. Useful for replay and debugging.
class_name GameHistory
extends RefCounted

## List of history entries.
var entries: Array[Dictionary] = []


## Records an action in the history.
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


## Returns the last history entry.
func get_last() -> Dictionary:
	return entries.back() if entries else {}


## Clears all history.
func clear() -> void:
	entries.clear()
