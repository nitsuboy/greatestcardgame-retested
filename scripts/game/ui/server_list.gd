class_name ServerList
extends Panel

var item: PackedScene = preload("res://scenes/server_item.tscn")
var connect_disabled: bool

@onready var container = $MarginContainer/VBoxContainer


func add_item(players, server_name) -> ServerItem:
	var new_item = item.instantiate()
	new_item.name_label.text = server_name
	new_item.players_label.text = players
	if connect_disabled:
		new_item.connect_button.disabled = true
	container.add_child(new_item)
	return new_item


func clear() -> void:
	for child in container.get_children():
		child.queue_free()


func disable_connect() -> void:
	for child in container.get_children():
		child.connect_button.disabled = true
		connect_disabled = true


func enable_connect() -> void:
	for child in container.get_children():
		child.connect_button.disabled = false
		connect_disabled = false
