extends Control


func _on_singleplayer_pressed() -> void:
	var lobby = preload("res://scenes/lobby.tscn").instantiate()
	var parent = get_parent()
	parent.add_child(lobby)

	var screen_size = get_viewport_rect().size

	lobby.position = Vector2(-screen_size.x, 0)

	var tween = create_tween()
	tween.set_parallel(true)
	(
		tween
		. tween_property($menu, "position", Vector2(screen_size.x, 0), 0.6)
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
			. tween_property(mat, "shader_parameter/wave_time_mul", -1.0, 2)
			. set_ease(Tween.EASE_OUT)
			. set_trans(Tween.TRANS_CUBIC)
		)

	await tween.finished


func _on_multiplayer_pressed() -> void:
	var lobby = preload("res://scenes/lobby.tscn").instantiate()
	var parent = get_parent()
	parent.add_child(lobby)

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


func on_multiplayer_back_pressed(lobby: Node) -> void:
	var screen_size = get_viewport_rect().size

	var tween = create_tween()
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


func _on_options_pressed() -> void:
	var lobby = preload("res://scenes/lobby.tscn").instantiate()
	var parent = get_parent()
	parent.add_child(lobby)

	var screen_size = get_viewport_rect().size

	lobby.position = Vector2(0, screen_size.y)

	var tween = create_tween()
	tween.set_parallel(true)
	(
		tween
		. tween_property($menu, "position", Vector2(0, -screen_size.y), 0.6)
		. set_ease(Tween.EASE_OUT)
		. set_trans(Tween.TRANS_CUBIC)
	)
	(
		tween
		. tween_property($background, "position", Vector2(0, -screen_size.y), 0.6)
		. set_ease(Tween.EASE_OUT)
		. set_trans(Tween.TRANS_CUBIC)
	)
	tween.tween_property(lobby, "position", Vector2(0, 0), 2).set_ease(Tween.EASE_OUT).set_trans(
		Tween.TRANS_CUBIC
	)

	await tween.finished
