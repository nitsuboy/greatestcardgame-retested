class_name TurnSystem
extends System


static func change_turn(
	entity: Entity, _comp: PlayableComponent, event_args: DropEventArgs
) -> void:
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


static func change_turn_request(num_of_turns: int) -> void:
	NetworkManager.client_request_action(
		NetworkManager.ActionWhere.GAME, GameManager.Actions.SKIP_TURN, num_of_turns
	)
