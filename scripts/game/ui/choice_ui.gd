class_name ChoiceUI
extends Control

static var _instance: ChoiceUI

var _title
var _options
var _panel


static func open(request_id: String, type: String, data: Dictionary, node: Node) -> void:
	if not _instance:
		_instance = ChoiceUI.new()
		_instance._build_ui()
		node.add_child(_instance)
	_instance._show(request_id, type, data)


static func close() -> void:
	if _instance:
		_instance.queue_free()
		_instance = null


func _show(request_id: String, type: String, _data: Dictionary) -> void:
	show()
	_title.text = type.capitalize()

	# Limpa opções anteriores
	for child in _options.get_children():
		child.queue_free()

	match type:
		"color":
			for color_name in ["Yellow", "Red", "Green", "Blue"]:
				_add_button(
					color_name,
					func():
						var idx = ["yellow", "red", "green", "blue"].find(color_name.to_lower())
						_submit(request_id, idx)
				)
		"target_player":
			for pid in Players.get_player_ids():
				if pid == multiplayer.get_unique_id():
					continue
				_add_button("Player %d" % pid, func(): _submit(request_id, pid))
		_:
			_add_button("Confirm", func(): _submit(request_id, true))


func _add_button(text: String, callback: Callable) -> void:
	var btn = Button.new()
	btn.text = text
	btn.pressed.connect(callback)
	_options.add_child(btn)


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

	_title = Label.new()
	_title.name = "Title"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_title)

	_options = VBoxContainer.new()
	_options.name = "Options"
	vbox.add_child(_options)

	hide()
	add_child(_panel)


func _submit(request_id: String, choice: Variant) -> void:
	Remote.send("choice_response", {"request_id": request_id, "choice": choice})
	hide()
