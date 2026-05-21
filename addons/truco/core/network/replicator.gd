## Synchronizes ECS state between server and clients via RPC.
##
## The server modifies components locally, packs the changes into
## batches, and sends them to all clients via RPC. Clients apply
## locally and confirm via SyncBarrier.
##
## Flow:
## 1. Server modifies components
## 2. push_state(batch, sync_id) → sends via RPC
## 3. Client receives, applies, emits batch_applied
## 4. Client confirms to server
class_name Replicator
extends SystemNode

## Emitted after a batch is applied (both server and client).
signal batch_applied(batch: Array[Dictionary], sync_id: String)


## Sends a batch of modified components to all peers.
## If connected_count <= 1, applies synchronously (single-player).
func push_state(batch: Array[Dictionary], sync_id: String) -> void:
	if Players.connected_count() <= 1:
		_apply_batch(batch, sync_id)
		Sync.start(sync_id)
		return
	_rpc_apply_batch.rpc(batch, sync_id)
	Sync.start(sync_id)


@rpc("authority", "call_local", "reliable")
func _rpc_apply_batch(batch: Array[Dictionary], sync_id: String) -> void:
	_apply_batch(batch, sync_id)
	Sync._rpc_confirm.rpc_id(1, sync_id, multiplayer.get_unique_id())


## Sends an entity deletion request to all peers.
func push_delete(entity: int, sync_id: String) -> void:
	if Players.connected_count() <= 1:
		_apply_deletion(entity)
		Sync.start(sync_id)
		return
	_rpc_apply_deletion.rpc(entity, sync_id)
	Sync.start(sync_id)


@rpc("authority", "call_local", "reliable")
func _rpc_apply_deletion(entity: int, sync_id: String) -> void:
	_apply_deletion(entity)
	Sync._rpc_confirm.rpc_id(1, sync_id, multiplayer.get_unique_id())


## Removes the NodeRef from the scene tree and deletes the entity from World.
func _apply_deletion(entity: int) -> void:
	if not world.entities.exists(entity):
		return
	if world.has_component(entity, NodeRef):
		var ref = world.get_component(entity, NodeRef) as NodeRef
		if ref and ref.node:
			ref.node.queue_free()
			ref.node = null
	world.delete_entity(entity)


## Applies a batch locally: creates/updates components and emits batch_applied.
func _apply_batch(batch: Array[Dictionary], sync_id: String = "") -> void:
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

	batch_applied.emit(batch, sync_id)
