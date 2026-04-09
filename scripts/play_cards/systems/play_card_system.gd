class_name PlayCardSystem
extends System


static func try_play_card(
	entity: Entity, _comp: PlayableComponent, event_args: DropEventArgs
) -> void:
	var dropzone = event_args.drop_zone

	if EntitySystem.has_comp(dropzone.entity, PlayZoneComponent):
		NetworkManager.client_request_action(
			NetworkManager.ActionWhere.GAME,
			GameManager.Actions.PLAY_CARD,
			entity.id,
			dropzone.entity.id
		)


static func play_card(entity: Entity, _comp: PlayableComponent, event_args: DropEventArgs) -> void:
	var dropzone = event_args.drop_zone

	var node_comp = EntitySystem.get_comp(entity, NodeComponent)
	var p = node_comp.node.global_position
	var parent = node_comp.node.get_parent()
	if not (node_comp.node.holder == dropzone.who_to_apply):
		node_comp.node.snap_pos = dropzone.global_rect.get_center()
		parent.remove_child(node_comp.node)
		dropzone.who_to_apply.add_card(node_comp.node)
		node_comp.node.global_position = p
		node_comp.node.rotation = 0

	if NetworkManager.multiplayer.is_server():
		var e_args = PlayCardEventArgs.new(entity, dropzone.entity)
		var e = PlayCardEvent.new(e_args)
		e.start()
