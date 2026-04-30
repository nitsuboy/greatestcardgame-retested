extends TabContainer

@onready var entity_list = $EntityList
@onready var component_list = $ComponentList


func _ready() -> void:
	entity_list.clear()
	for e in EntityRegistry.get_all_entities():
		entity_list.add_item(str(e))


func update_list() -> void:
	entity_list.clear()
	for e in EntityRegistry.get_all_entities():
		entity_list.add_item(str(e))


func get_filename(path: String) -> String:
	var clean_path = path.split("):")[0]
	var basename = clean_path.get_file().get_basename()
	var formatted = basename.capitalize().replace("_", " ")
	return formatted


func _on_item_list_item_selected(index: int) -> void:
	var ent = int(entity_list.get_item_text(index))
	component_list.entity_id = ent
	component_list.update_list()


func _on_window_close_requested() -> void:
	$"..".hide()


func _on_button_2_pressed() -> void:
	$"..".show()
