## Card drop detection system.
##
## When a card is dropped (on_card_dropped), checks if the target zone
## is different from the current one and sends a "play_card" action via RemoteAction.
class_name DropSystem
extends SystemNode


func init_system() -> void:
	world.events.on_card_dropped.connect(_on_drop)


func _on_drop(entity: int, zone: Node) -> void:
	var zid = zone.zone_id
	var card = world.get_component(entity, CardComponent) as CardComponent
	if card and card.zone_id == zid:
		return
	Remote.send("play_card", {"entity": entity, "zone": zid})
