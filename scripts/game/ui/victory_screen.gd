class_name VictoryScreen
extends Control

static var _instance: VictoryScreen

var _winner_label: Label
var _panel: Panel
var _game_node: Node


static func open(winner_id: int, node: Node) -> void:
	if not _instance:
		_instance = VictoryScreen.new()
		_instance._build_ui()
		node.add_child(_instance)
	_instance._game_node = node
	_instance._show(winner_id)


static func close() -> void:
	if _instance:
		_instance.queue_free()
		_instance = null


func _show(winner_id: int) -> void:
	show()
	_winner_label.text = "Jogador %d venceu!" % winner_id


func _build_ui() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	_panel = Panel.new()
	_panel.custom_minimum_size = Vector2(508, 508)
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_panel.position = Vector2(-254, -254)

	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	_panel.add_child(vbox)

	_winner_label = Label.new()
	_winner_label.name = "Title"
	_winner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_winner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_winner_label.size_flags_horizontal = SIZE_EXPAND
	_winner_label.size_flags_vertical = SIZE_EXPAND
	vbox.add_child(_winner_label)

	var btn = Button.new()
	btn.text = "Voltar ao Lobby"
	btn.pressed.connect(_return_to_lobby)
	vbox.add_child(btn)

	hide()
	add_child(_panel)


func _exit_tree() -> void:
	if _instance == self:
		_instance = null


func _return_to_lobby() -> void:
	get_tree().root.get_node("/root/Game")._return_to_lobby()
