extends ColorRect


func set_color_shader(color: Color):
	material.set("shader_parameter/top_color", color)


func change_direction(bl: bool):
	if bl:
		material.set("shader_parameter/wave_time_mul", -.1)
	else:
		material.set("shader_parameter/wave_time_mul", 0.1)
