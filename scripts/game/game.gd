extends Node2D

var _curve
var _returning: bool = false


func _ready() -> void:
	_create_player_hands()
	_connect_choice_ui()
	if multiplayer.is_server():
		call_deferred("_start_game")

	if multiplayer.is_server():
		Conn.disconnected.connect(_return_to_lobby)
	Conn.server_disconnected.connect(_return_to_lobby)


func _connect_choice_ui() -> void:
	var choice_sys = $WorldRunner/PlayerChoiceSystem
	if choice_sys:
		choice_sys.choice_ui_requested.connect(
			func(request_id: String, type: String, data: Dictionary):
				ChoiceUI.open(request_id, type, data, $front)
		)


func _start_game() -> void:
	Remote.send("start_game", {})


func _create_player_hands() -> void:
	var ids = Players.get_player_ids()
	var count = ids.size()
	var view = get_viewport_rect()
	var PlayerScene = preload("res://scenes/player.tscn")
	var local_index = Players.get_player_ids().find(multiplayer.get_unique_id())
	_curve = CurveHelper.make_rounded_square(view.size, 50., 100.)

	for i in count:
		var pid = ids[i]
		var player: Node2D = PlayerScene.instantiate()
		var t = fposmod((i - local_index) / float(count), 1.0)
		player.name = "Player_%d" % pid
		player.zone_id = pid
		player.transform = CurveHelper.get_point_on_path(_curve, t) * Transform2D(PI, Vector2.ZERO)
		player.scale = Vector2.ONE * .5

		var label = player.get_node("Label") as Label
		if label:
			label.text = Players.get_player(pid).get("name", "Player %d" % pid)
			label.rotation = -player.rotation
			if pid == multiplayer.get_unique_id():
				label.hide()

		$Zones/Players.add_child(player)


# Em game.gd
func _return_to_lobby(_unused: int = 0) -> void:
	if _returning:
		return
	_returning = true

	Conn.leave()
	Sync.clear()
	Players.clear()

	queue_free()

	# Reseta UI do lobby
	var lobby = get_node("../MainMenu/Lobby")  # ajuste o path
	if lobby:
		lobby._stop_server()
		lobby._update_ui()
	get_node("../MainMenu").show()
