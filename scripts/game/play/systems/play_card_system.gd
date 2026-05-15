class_name PlayCardSystem
extends SystemNode

var _seq: int = 0
var _play_seq: int = 0


func init_system() -> void:
	world.get_system(ValidationSystem).action_validated.connect(_on_action)
	replicator.batch_applied.connect(_on_batch_applied)


func _on_action(sender: int, action: String, data: Dictionary) -> void:
	if action != "play_card":
		return
	if not multiplayer.is_server():
		return

	var entity = data.entity
	if not world.entities.exists(entity) or not world.has_component(entity, CardComponent):
		return

	var card = world.get_component(entity, CardComponent)
	card.zone_id = data.get("zone", 999)
	card.face_up = true
	_play_seq += 1
	card.play_order = _play_seq

	var sync_id = "play_%d" % _seq
	_seq += 1
	replicator.push_state(
		[{"entity": entity, "type": CardComponent.resource_path, "data": card.to_dict()}], sync_id
	)
	await get_tree().process_frame
	world.events.on_card_played.emit(entity, sender)


func _on_batch_applied(batch: Array[Dictionary], _sync_id: String) -> void:
	for entry in batch:
		if entry.type == CardComponent.resource_path:
			_reparent_card(entry.entity)


func _reparent_card(entity: int) -> void:
	if not world.has_component(entity, NodeRef):
		return
	var ref = world.get_component(entity, NodeRef) as NodeRef
	if not ref or not ref.node:
		return
	var card = world.get_component(entity, CardComponent) as CardComponent
	if not card:
		return

	var zone = Zones.get_zone(card.zone_id)
	if not zone:
		return

	var effective: Node = zone
	var c = zone.get("container")
	if c:
		effective = c

	if ref.node.get_parent() == effective:
		return
	var pos_snap = ref.node.global_position
	var old = ref.node.get_parent()
	if old:
		old.remove_child(ref.node)
	zone.add_card(ref.node)
	ref.node.update_visual()
	ref.node.global_position = pos_snap
	if old and old.has_method("update_cards"):
		old.update_cards()
