extends Node2D

class_name Dice

func Roll() -> int:
	var result : int = randi_range(1,6)
	return result
