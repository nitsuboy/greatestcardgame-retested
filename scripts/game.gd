extends Node2D

var _curve


func _ready() -> void:
	_create_player_hands()
	if multiplayer.is_server():
		Remote.send("start_game", {})


func _create_player_hands() -> void:
	var ids = Players.get_player_ids()
	var count = ids.size()
	var view = get_viewport_rect()
	var player_scene = preload("res://scenes/player.tscn")
	var local_index = Players.get_player_ids().find(multiplayer.get_unique_id())
	_curve = CurveHelper.make_rounded_square(view.size, 50., 100.)

	for i in count:
		var pid = ids[i]
		var player: Node2D = player_scene.instantiate()
		var t = fposmod((i - local_index) / float(count), 1.0)
		player.name = "Player_%d" % pid
		player.zone_id = pid
		player.transform = CurveHelper.get_point_on_path(_curve, t) * Transform2D(PI, Vector2.ZERO)
		player.scale = Vector2.ONE * .5

		$Zones/Players.add_child(player)
