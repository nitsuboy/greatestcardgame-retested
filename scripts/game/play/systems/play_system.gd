class_name PlayCardSystem
extends SystemNode

var _seq: int = 0


func init_system() -> void:
	world.get_system(ValidationSystem).action_validated.connect(_on_action)


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

	# Atualiza top_card_entity no ValidationSystem
	var val_sys = get_parent().validation_system
	if val_sys:
		val_sys._top_card_entity = entity

	var sync_id = "play_%d" % _seq
	_seq += 1
	replicator.push_state(
		[{"entity": entity, "type": CardComponent.resource_path, "data": card.to_dict()}], sync_id
	)

	# Notifica EffectSystem com o jogador que jogou
	world.events.on_card_played.emit(entity, sender)
