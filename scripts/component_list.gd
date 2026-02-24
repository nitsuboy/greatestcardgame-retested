extends Control

var items: Dictionary[String,Component] = {}
var components: Array = []
var entity_id: int
var pop_up: PopupMenu

@onready var list_container = $MarginContainer/VBoxContainer
@onready var property_list = $"../PropertyList"


func _ready():
	pop_up = PopupMenu.new()
	pop_up.id_pressed.connect(_on_popup_pressed)
	components = load_component_scripts("res://scripts/")
	for i in components.size():
		pop_up.add_item(get_filename(str(components[i])))
	add_child(pop_up)
	update_list()


func load_component_scripts(path: String) -> Array:
	var dir = DirAccess.open(path)
	var result = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if not file_name.begins_with("."):
					result += load_component_scripts(path + "/" + file_name)
			else:
				if file_name.ends_with("_component.gd"):
					var script = load(path + "/" + file_name)
					if script:
						result.append(script)
			file_name = dir.get_next()
		dir.list_dir_end()
	return result


func get_filename(path: String) -> String:
	var clean_path = path.split("):")[0]
	var basename = clean_path.get_file().get_basename()
	var formatted = basename.capitalize().replace("_", " ")
	return formatted


func update_list():
	for c in list_container.get_children():
		c.queue_free()
	items.clear()
	if not Entity.all_entities.has(entity_id):
		return
	for c in Entity.all_entities[entity_id].components:
		items[get_filename(str(c.get_script()))] = c
	var aux = 0
	for i in items:
		var hbox = HBoxContainer.new()

		var label = Label.new()
		label.text = i
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		hbox.add_child(label)

		var edit_button = Button.new()
		edit_button.text = "Editar"
		edit_button.pressed.connect(_on_edit_pressed.bind(aux, i))
		hbox.add_child(edit_button)

		var delete_button = Button.new()
		delete_button.text = "Excluir"
		delete_button.pressed.connect(_on_delete_pressed.bind(aux))
		hbox.add_child(delete_button)

		list_container.add_child(hbox)
		aux += 1

	# Botão para adicionar novo item
	var add_button = Button.new()
	add_button.text = "Adicionar"
	add_button.pressed.connect(_on_add_pressed)
	list_container.add_child(add_button)

	var ent_del_button = Button.new()
	ent_del_button.text = "Deletar entidade"
	ent_del_button.pressed.connect(_on_ent_del_pressed)
	list_container.add_child(ent_del_button)


func _on_edit_pressed(index, c_name):
	$"..".set_tab_title(2, c_name)
	property_list.generate_editor(Entity.all_entities[entity_id].components[index])
	update_list()


func _on_delete_pressed(index):
	Entity.all_entities[entity_id].components.remove_at(index)
	update_list()


func _on_add_pressed():
	pop_up.show()


func _on_ent_del_pressed():
	var node_comp = EntitySystem.get_comp(Entity.all_entities[entity_id], NodeComponent)
	if node_comp:
		node_comp.node.queue_free()
	Entity.all_entities.erase(entity_id)
	update_list()


func _on_popup_pressed(id):
	Entity.all_entities[entity_id].components.append(components[id].new())
	update_list()
