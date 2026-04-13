extends Control


func _on_singleplayer_pressed() -> void:
	pass  # Replace with function body.


func _on_multiplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")


func _on_options_pressed() -> void:
	pass  # Replace with function body.
