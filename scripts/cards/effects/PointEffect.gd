extends Effect

class_name PointEffect

@export var point : int = 1

func ApplyEffect(_card: Card,_argument: Variant,_argument2: Variant) -> Variant:
	if _argument is Player:
		_argument.points += point 
	return null
