extends Node2D

class_name Dice

signal Rolled(value : int)

@export var sides : int = 6

func Roll() -> int:
	var result : int = randi() % sides + 1
	emit_signal("Rolled", result)
	return result

func IsInRange(value: int, min_val: int, max_val: int) -> bool:
	return value >= min_val and value<=max_val
