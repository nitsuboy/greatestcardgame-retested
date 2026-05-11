class_name DrawStackComponent
extends Component

@export var accumulated: int = 0


func to_dict() -> Dictionary:
	return {"accumulated": accumulated}


func from_dict(data: Dictionary) -> void:
	accumulated = data.get("accumulated", 0)
