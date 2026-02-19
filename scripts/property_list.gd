extends Control

var target_object: Object

@onready var list_container = $MarginContainer/VBoxContainer


func generate_editor(obj: Object):
	for c in list_container.get_children():
		c.queue_free()

	var props = obj.get_property_list()
	for prop in props:
		var prop_name = prop.name
		if prop_name.contains("resource"):
			continue
		var prop_type = prop.type

		var hbox = HBoxContainer.new()

		var label = Label.new()
		label.text = prop_name.capitalize()
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		hbox.add_child(label)

		var editor
		match prop_type:
			TYPE_STRING:
				editor = LineEdit.new()
				editor.text = str(obj.get(prop_name))
				editor.text_submitted.connect(_on_value_changed.bind(obj, prop_name, prop_type))
			TYPE_INT, TYPE_FLOAT:
				editor = LineEdit.new()
				editor.text = str(obj.get(prop_name))
				editor.text_submitted.connect(_on_value_changed.bind(obj, prop_name, prop_type))
			TYPE_BOOL:
				editor = CheckBox.new()
				editor.button_pressed = obj.get(prop_name)
				editor.toggled.connect(_on_value_changed.bind(obj, prop_name, prop_type))
			_:
				pass
		if editor:
			hbox.add_child(editor)
			list_container.add_child(hbox)


func _on_value_changed(value, obj: Object, prop_name: String, prop_type):
	match prop_type:
		TYPE_INT:
			obj.set(prop_name, int(value))
		TYPE_FLOAT:
			obj.set(prop_name, float(value))
		TYPE_BOOL:
			obj.set(prop_name, value)
		TYPE_STRING:
			obj.set(prop_name, str(value))
