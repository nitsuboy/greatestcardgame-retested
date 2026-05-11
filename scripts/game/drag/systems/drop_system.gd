class_name DropSystem
extends SystemNode


func init_system() -> void:
	world.events.on_card_dropped.connect(_on_drop)


func _on_drop(entity: int, zone: Node) -> void:
	if not multiplayer.is_server():
		return
	print("droped")
	var zid = zone.zone_id if zone.has_method("get_zone_id") else 999
	Remote.send("play_card", {"entity": entity, "zone": zid})
