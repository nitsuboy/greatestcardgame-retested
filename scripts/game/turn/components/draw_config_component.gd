class_name DrawConfigComponent
extends Component

enum DrawMode { DRAW_ONE_PASS, DRAW_UNTIL_PLAYABLE }

@export var draw_mode: int = DrawMode.DRAW_ONE_PASS
@export var draw_on_empty_hand: bool = true


func to_dict() -> Dictionary:
	return {"draw_mode": draw_mode, "draw_on_empty_hand": draw_on_empty_hand}


func from_dict(data: Dictionary) -> void:
	draw_mode = data.get("draw_mode", DrawMode.DRAW_ONE_PASS)
	draw_on_empty_hand = data.get("draw_on_empty_hand", true)
