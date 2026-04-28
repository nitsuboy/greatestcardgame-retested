class_name PlayCardSystem
extends System


static func initialize():
	EventSystem.InscreverEventoLocal(
		PlayableComponent, DropEvent, Callable(PlayCardSystem, "on_drop")
	)


static func on_drop(_entity: Entity, _comp: PlayableComponent, _args: DropEvent) -> void:
	var dropzone = _args.drop_zone
	var pz_comp: PlayZoneComponent = EntitySystem.get_comp(dropzone.entity, PlayZoneComponent)

	if not pz_comp:
		return

	if _entity.id in pz_comp.ent_on_playzone:
		return

	Net.client_request_action(
		Net.multiplayer.get_unique_id(),
		Net.ActionWhere.GAME,
		GameManager.Actions.PLAY_CARD,
		_entity.id,
		dropzone.entity.id
	)


static func play_card(entity: Entity, dropzone: DropZone) -> void:
	var pz_comp: PlayZoneComponent = EntitySystem.get_comp(dropzone.entity, PlayZoneComponent)

	var node_comp = EntitySystem.get_comp(entity, NodeComponent)
	var p = node_comp.node.global_position
	var parent = node_comp.node.get_parent()
	if not (node_comp.node.holder == dropzone.who_to_apply):
		pz_comp.ent_on_playzone.append(entity.id)
		node_comp.node.snap_pos = dropzone.global_rect.get_center()
		parent.remove_child(node_comp.node)
		dropzone.who_to_apply.add_card(node_comp.node)
		node_comp.node.global_position = p
		node_comp.node.rotation = 0

	node_comp.node.flip(false)

	if Net.multiplayer.is_server():
		var ev = PlayCardEvent.new(dropzone.entity)
		EventSystem.IniciarEventoLocal(entity, ev)
