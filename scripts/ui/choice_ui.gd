class_name ChoiceUI
extends Control

static var _instance: ChoiceUI

@onready var _title = $VBoxContainer/Title
@onready var _options = $VBoxContainer/Options
@onready var _panel = $Panel


static func open(request_id: String, type: String, data: Dictionary) -> void:
	if not _instance:
		#var scene = preload("res://scenes/choice_ui.tscn")
		#_instance = scene.instantiate()
		#get_tree().root.add_child(_instance)
		pass
	_instance._show(request_id, type, data)


static func close() -> void:
	if _instance:
		_instance.queue_free()
		_instance = null


func _show(request_id: String, type: String, data: Dictionary) -> void:
	_panel.visible = true
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


func _submit(request_id: String, choice: Variant) -> void:
	Remote.send("choice_response", {"request_id": request_id, "choice": choice})
	_panel.visible = false
