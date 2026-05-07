class_name CurveHelper
extends RefCounted


static func make_rounded_square(
	screen_size: Vector2, corner_radius: float = 50.0, margin: float = 50.0
) -> Curve2D:
	var w = screen_size.x
	var h = screen_size.y
	var curve = Curve2D.new()

	curve.add_point(Vector2(w / 2, h - margin))
	curve.add_point(Vector2(margin + corner_radius, h - margin))
	curve.add_point(Vector2(margin, h - margin - corner_radius))
	curve.add_point(Vector2(margin, margin + corner_radius))
	curve.add_point(Vector2(margin + corner_radius, margin))
	curve.add_point(Vector2(w - margin - corner_radius, margin))
	curve.add_point(Vector2(w - margin, margin + corner_radius))
	curve.add_point(Vector2(w - margin, h - margin - corner_radius))
	curve.add_point(Vector2(w - margin - corner_radius, h - margin))
	curve.add_point(Vector2(w / 2, h - margin))

	return curve


static func get_point_on_path(curve: Curve2D, t: float) -> Transform2D:
	t = clamp(t, 0.0, 1.0)
	return curve.sample_baked_with_rotation(t * curve.get_baked_length())
