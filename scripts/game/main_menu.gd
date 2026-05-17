extends Control


func _on_multiplayer_pressed() -> void:
	var lobby = preload("res://scenes/lobby.tscn").instantiate()
	add_child(lobby)

	var screen_size = get_viewport_rect().size

	lobby.position = Vector2(screen_size.x, 0)

	var tween = create_tween()
	tween.set_parallel(true)
	(
		tween
		. tween_property($menu, "position", Vector2(-screen_size.x, 0), 0.6)
		. set_ease(Tween.EASE_OUT)
		. set_trans(Tween.TRANS_CUBIC)
	)
	tween.tween_property(lobby, "position", Vector2(0, 0), 2).set_ease(Tween.EASE_OUT).set_trans(
		Tween.TRANS_CUBIC
	)

	var mat = $background.material
	if mat:
		(
			tween
			. tween_property(mat, "shader_parameter/wave_time_mul", 1.0, 2)
			. set_ease(Tween.EASE_OUT)
			. set_trans(Tween.TRANS_CUBIC)
		)

	await tween.finished
	$menu.hide()


func on_multiplayer_back_pressed(lobby: Node) -> void:
	var screen_size = get_viewport_rect().size

	var tween = create_tween()
	$menu.show()
	tween.set_parallel(true)
	tween.tween_property($menu, "position", Vector2(0, 0), 2).set_ease(Tween.EASE_OUT).set_trans(
		Tween.TRANS_CUBIC
	)
	(
		tween
		. tween_property(lobby, "position", Vector2(screen_size.x, 0), 0.6)
		. set_ease(Tween.EASE_OUT)
		. set_trans(Tween.TRANS_CUBIC)
	)

	var mat = $background.material
	if mat:
		(
			tween
			. tween_property(mat, "shader_parameter/wave_time_mul", .1, 2)
			. set_ease(Tween.EASE_OUT)
			. set_trans(Tween.TRANS_CUBIC)
		)

	await tween.finished
