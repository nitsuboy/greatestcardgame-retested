class_name PlayCardSystem
extends System

static func TryPlayCard(entity: Entity, _comp: PlayableComponent, event_args: DropEventArgs) -> void:
	var dropzone = event_args.drop_zone
	print("try")
	
	if EntitySystem.has_comp(dropzone.entity, PlayZoneComponent):
		NetworkManager.request_action(1,0,entity.id, dropzone.entity.id)

static func PlayCard(entity: Entity, _comp: PlayableComponent, event_args: DropEventArgs) -> void:
	var dropzone = event_args.drop_zone
	
	var node_comp = EntitySystem.get_comp(entity, NodeComponent)
	var p = node_comp.node.global_position
	var parent = node_comp.node.get_parent()
	node_comp.node.snap_pos = dropzone.global_rect.get_center()
	if not parent == dropzone.who_to_apply:
		parent.remove_child(node_comp.node)
		dropzone.who_to_apply.add_card(node_comp.node)
		node_comp.node.global_position = p
		node_comp.node.rotation = 0
	
