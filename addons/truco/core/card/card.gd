@abstract
class_name Card
extends Control

const SIZE := Vector2(200, 200)

@export var card_data: CardData
var entity_id: int = -1
var world: World

func post_instantiate(w: World, id: int) -> void:
	world = w
	entity_id = id


func _on_gui_input(event: InputEvent) -> void:
	if entity_id == -1 or not world:
		return
	world.events.on_card_input.emit(entity_id, event)


func _on_mouse_entered() -> void:
	if entity_id == -1 or not world:
		return
	world.events.on_card_mouse_entered.emit(entity_id)


func _on_mouse_exited() -> void:
	if entity_id == -1 or not world:
		return
	world.events.on_card_mouse_exited.emit(entity_id)


func card_is_focused(value: bool) -> void:
	z_index = 10 if value else 0
