## Abstract base class for card visuals.
##
## Emits input/hover signals on the EventBus (on_card_input,
## on_card_mouse_entered/exited). Should be extended to
## customize card appearance for the specific game.
@abstract class_name Card3D
extends MeshInstance3D

const SIZE := Vector2(200, 200)

## Serializable data associated with this card.
@export var card_data: CardData
## ECS entity ID linked to this visual.
var entity_id: int = -1
## Reference to the ECS World.
var world: World


## Links this visual to an ECS entity.
func post_instantiate(w: World, id: int) -> void:
	world = w
	entity_id = id


func _on_input_event(
	_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int
) -> void:
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


## Toggles the card's visual focus (z-index).
func card_is_focused(_value: bool) -> void:
	pass
