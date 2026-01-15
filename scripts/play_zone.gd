class_name PlayZone
extends Control

signal card_played

@export var static_container: VStaticContainer


func emit_play():
	card_played.emit()
