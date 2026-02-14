class_name ServerItem
extends HBoxContainer

@export var name_label: Label
@export var players_label: Label
@export var connect_button: Button

var server_name: String = "":
	set(value):
		server_name = value
		name_label.text = value

var players: String = "":
	set(value):
		players = value
		players_label.text = value
