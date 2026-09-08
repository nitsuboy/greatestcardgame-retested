## Card click system.
##
## When a card is clicked (on_card_clicked), checks if the target zone
## is different from the current one and sends a "play_card" action via Remote.
class_name ClickSystem
extends SystemNode


func init_system() -> void:
	world.events.on_card_clicked.connect(_on_click)


func _on_click(entity: int, zone: int) -> void:
	var card = world.get_component(entity, CardComponent) as CardComponent
	if card and card.zone_id == zone:
		return
	Remote.send("play_card", {"entity": entity, "zone": zone})