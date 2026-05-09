class_name PlaySystem
extends SystemNode


func _ready() -> void:
	world.events.on_card_dropped.connect(_on_card_dropped)


func _on_card_dropped(entity_id: int, dropzone: Node) -> void:
	if not world.has_component(entity_id, PlayableComponent):
		return

	var dropzone_comp: PlayZoneComponent = world.get_component(
		dropzone.entity_id, PlayZoneComponent
	)
	if not dropzone_comp:
		return

	if entity_id in dropzone_comp.ent_on_playzone:
		return

	Net.client_request_action(
		Conn.multiplayer.get_unique_id(),
		Net.ActionWhere.GAME,
		GameManager.Actions.PLAY_CARD,
		entity_id,
		dropzone.entity_id
	)


func play_card(world: World, entity_id: int, dropzone_entity_id: int) -> void:
	var ref: CardNodeRef = world.get_component(entity_id, CardNodeRef)
	if not ref:
		return

	var card_node = ref.node
	var dropzone: DropZone = _find_dropzone_by_entity(dropzone_entity_id)
	if not dropzone:
		return

	var pz_comp: PlayZoneComponent = world.get_component(dropzone_entity_id, PlayZoneComponent)

	var parent = card_node.get_parent()
	if card_node.holder != dropzone.who_to_apply:
		pz_comp.ent_on_playzone.append(entity_id)
		card_node.snap_pos = dropzone.global_rect.get_center()
		parent.remove_child(card_node)
		dropzone.who_to_apply.add_card(card_node)
		card_node.global_position = card_node.snap_pos
		card_node.rotation = 0

	card_node.flip(false)
	world.events.on_card_played.emit(entity_id, dropzone_entity_id)


func _find_dropzone_by_entity(entity_id: int) -> DropZone:
	for dz in get_tree().get_nodes_in_group("dropplace"):
		if dz is DropZone and dz.entity_id == entity_id:
			return dz
	return null
