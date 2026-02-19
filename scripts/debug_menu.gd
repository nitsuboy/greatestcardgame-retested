extends TabContainer


func _ready() -> void:
	$ItemList.clear()
	for e in Entity.all_entities:
		$ItemList.add_item(str(e))


func get_filename(path: String) -> String:
	var clean_path = path.split("):")[0]
	var basename = clean_path.get_file().get_basename()
	var formatted = basename.capitalize().replace("_", " ")
	return formatted


func _on_item_list_item_selected(index: int) -> void:
	var ent = int($ItemList.get_item_text(index))
	$Panel.entity_id = ent
	$Panel.update_list()


func _on_window_close_requested() -> void:
	$"..".hide()


func _on_button_2_pressed() -> void:
	print("teste")
	$"..".show()
