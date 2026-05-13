class_name Replicator
extends SystemNode

signal batch_applied(batch: Array[Dictionary], sync_id: String)


func push_state(batch: Array[Dictionary], sync_id: String) -> void:
	if Players.connected_count() <= 1:
		_apply_batch(batch)
		Sync.start(sync_id)
		return
	_rpc_apply_batch.rpc(batch, sync_id)
	Sync.start(sync_id)


@rpc("authority", "call_local", "reliable")
func _rpc_apply_batch(batch: Array[Dictionary], sync_id: String) -> void:
	_apply_batch(batch)
	Sync._rpc_confirm.rpc_id(1, sync_id, multiplayer.get_unique_id())


func _apply_batch(batch: Array[Dictionary]) -> void:
	for entry in batch:
		var entity: int = entry.entity
		var type: Script = load(entry.type)
		var data: Dictionary = entry.data

		if not world.entities.exists(entity):
			world.entities.force_create(entity)

		if world.has_component(entity, type):
			var comp = world.get_component(entity, type)
			if comp.has_method("from_dict"):
				comp.from_dict(data)
		else:
			var comp: Resource = type.new()
			if comp.has_method("from_dict"):
				comp.from_dict(data)
			world.add_component(entity, comp)

	batch_applied.emit(batch, "")
