extends Control

var items: Dictionary[String,Component] = {}
var scripts: Dictionary[int,Script] = {}
var entity_id: int
var pop_up: PopupMenu

@onready var list_container = $MarginContainer/VBoxContainer
@onready var property_list = $"../PropertyList"


func _ready() -> void:
	pop_up = PopupMenu.new()
	pop_up.id_pressed.connect(_on_popup_pressed)
	var aux: int = 0
	for i in ComponentRegistry.get_all_component_names():
		pop_up.add_item(i)
		scripts[aux] = ComponentRegistry.get_component_type(i)
		aux += 1
	add_child(pop_up)
	update_list()


func update_list() -> void:
	for c in list_container.get_children():
		c.queue_free()
	items.clear()
	var entity = EntityRegistry.get_entity(entity_id)
	if not entity:
		return
	for c: Component in EntitySystem.get_all_comps(entity):
		var s: Script = c.get_script()
		items[s.get_global_name()] = c
	for i in items:
		var hbox = HBoxContainer.new()

		var label = Label.new()
		label.text = i
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		hbox.add_child(label)

		var edit_button = Button.new()
		edit_button.text = "Editar"
		edit_button.pressed.connect(_on_edit_pressed.bind(i))
		hbox.add_child(edit_button)

		var delete_button = Button.new()
		delete_button.text = "Excluir"
		delete_button.pressed.connect(_on_delete_pressed.bind(i))
		hbox.add_child(delete_button)

		list_container.add_child(hbox)

	# Botão para adicionar novo item
	var add_button = Button.new()
	add_button.text = "Adicionar"
	add_button.pressed.connect(_on_add_pressed)
	list_container.add_child(add_button)

	var ent_del_button = Button.new()
	ent_del_button.text = "Deletar entidade"
	ent_del_button.pressed.connect(_on_ent_del_pressed)
	list_container.add_child(ent_del_button)


func _on_edit_pressed(c_name) -> void:
	$"..".set_tab_title(2, c_name)
	property_list.generate_editor(
		EntitySystem.get_comp(
			EntityRegistry.get_entity(entity_id), ComponentRegistry.get_component_type(c_name)
		)
	)
	update_list()


func _on_delete_pressed(c_name) -> void:
	EntitySystem.remove_comp(
		EntityRegistry.get_entity(entity_id), ComponentRegistry.get_component_type(c_name)
	)
	update_list()


func _on_add_pressed() -> void:
	pop_up.show()


func _on_ent_del_pressed() -> void:
	EntityRegistry.delete_entity(entity_id)
	update_list()


func _on_popup_pressed(id) -> void:
	ComponentRegistry.add_component_to_entity(entity_id, scripts[id].new())
	update_list()
