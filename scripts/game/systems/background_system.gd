class_name BackgroundSystem
extends SystemNode
const CARD_COLORS := {
	0: Color.YELLOW,
	1: Color.FIREBRICK,
	2: Color.SEA_GREEN,
	3: Color.NAVY_BLUE,
}

@export var target: ColorRect
@export var shader_speed: float = 0.4

var _tween: Tween
var _latest_play_order: int = 0


func init_system() -> void:
	replicator.batch_applied.connect(_on_batch_applied)


func _on_batch_applied(batch: Array[Dictionary], _sync_id: String) -> void:
	for entry in batch:
		if entry.type == TurnComponent.resource_path:
			var direction: int = entry.data.get("direction", 1)
			_tween_parameter("wave_time_mul", shader_speed * direction, 0.3)
		elif entry.type == UnoCardComponent.resource_path:
			var color: int = entry.data.get("color", -1)
			if color >= 0 and color < 4:
				if world.has_component(entry.entity, CardComponent):
					var cc = world.get_component(entry.entity, CardComponent) as CardComponent
					if cc.zone_id == 999:
						_tween_parameter("top_color", CARD_COLORS[color], 0.2)
		elif entry.type == CardComponent.resource_path:
			var play_order = entry.data.get("play_order", 0)
			if entry.data.get("zone_id") == 999 and play_order > _latest_play_order:
				var uno = world.get_component(entry.entity, UnoCardComponent) as UnoCardComponent
				if uno and uno.color >= 0 and uno.color < 4:
					_tween_parameter("top_color", CARD_COLORS[uno.color], 0.2)
			_latest_play_order = max(_latest_play_order, play_order)


func _tween_parameter(param: String, target_val: Variant, duration: float) -> void:
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_method(
		func(v): target.material.set("shader_parameter/%s" % param, v),
		target.material.get("shader_parameter/%s" % param),
		target_val,
		duration
	)
