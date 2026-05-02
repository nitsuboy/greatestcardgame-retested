extends Control


func _ready() -> void:
	var aux = 0
	for i: Button in get_children():
		aux += 1
		i.pressed.connect(request_color_change.bind(aux))


func request_color_change(color: int) -> void:
	Net.request_action(
		multiplayer.get_unique_id(),
		multiplayer.get_unique_id(),
		Net.ActionWhere.GAME,
		GameManager.Actions.CHANGE_COLOR,
		[color]
	)
	queue_free()
