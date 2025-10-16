class_name PointEffect
extends Effect

@export var point: int = 1


func apply_effect(_card: Card, _argument: Variant, _argument2: Variant) -> Variant:
	if _argument is Player:
		_argument.points += point
	return null
