extends Node2D

var _curve
var _returning: bool = false


func _ready() -> void:
	_create_player_hands()
	if multiplayer.is_server():
		call_deferred("_start_game")

	if multiplayer.is_server():
		Conn.disconnected.connect(_return_to_lobby)
	Conn.server_disconnected.connect(_return_to_lobby)


func _start_game() -> void:
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


func _return_to_lobby() -> void:
	if _returning:
		return
	_returning = true

	var was_server := multiplayer.is_server()
	if was_server:
		Conn.leave()

	queue_free()

	for child in get_tree().root.get_children():
		if child is Lobby:
			child.show()
			child._stop_server()
			Players.clear()
			return

	get_tree().change_scene_to_file("res://scenes/lobby.tscn")
