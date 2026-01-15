extends Path2D


func _ready() -> void:
	for p in rounded_rect_points(10.0, 10.0, 1.0):
		curve.add_point(p)


func rounded_rect_points(
	width: float, height: float, radius: float, segments: int = 8
) -> PackedVector2Array:
	var points := PackedVector2Array()
	radius = min(radius, width * 0.5, height * 0.5)
	var w = width * 0.5
	var h = height * 0.5
	# Centros dos arcos (cantos)
	var corners = [
		Vector2(w - radius, -h + radius),  # topo direito
		Vector2(w - radius, h - radius),  # baixo direito
		Vector2(-w + radius, h - radius),  # baixo esquerdo
		Vector2(-w + radius, -h + radius)  # topo esquerdo
	]
	var start_angles = [-PI / 2, 0, PI / 2, PI]
	for i in range(4):
		var center = corners[i]
		var start_angle = start_angles[i]
		var end_angle = start_angle + PI / 2
		for j in range(segments + 1):
			var t = float(j) / segments
			var angle = lerp(start_angle, end_angle, t)
			points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return points
