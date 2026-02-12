class_name PlayCardSystem
extends System

static func TryPlayCard(entity: Entity, _comp: PlayableComponent, event_args: DropEventArgs) -> void:
	var dropzone = event_args.drop_zone
	
	if DropZone.has_comp(dropzone, PlayZoneComponent):
		PlayCard(entity, _comp, event_args)

static func PlayCard(entity: Entity, _comp: PlayableComponent, event_args: DropEventArgs) -> void:
	var dropzone = event_args.drop_zone
	
	var node_comp = EntitySystem.get_comp(entity, NodeComponent)
	node_comp.snap_pos = dropzone.global_rect.get_center()
