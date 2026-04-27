class_name EntitySystem
extends System


## Retorna verdadeiro se a entidade tem um componente de determinado tipo, falso se não
static func has_comp(entity: Entity, comp_type: Script) -> bool:
	for component in entity.components:
		if component.get_script() == comp_type:
			return true
	return false


## Retorna o componente de determinado tipo se a entidade tiver, caso contrário retorna null
static func get_comp(entity: Entity, comp_type: Script) -> Component:
	for component in entity.components:
		if component.get_script() == comp_type:
			return component
	return null


## Retorna os componentes de determinado tipo se a entidade tiver, caso contrário retorna []
static func get_comps(entity: Entity, comp_type: Array[Script]) -> Array[Component]:
	var arr_aux: Array[Component] = []
	for component in entity.components:
		if component.get_script() in comp_type:
			arr_aux.append(component)
	return arr_aux


## Retorna os componentes que herdam de comp_parent
static func get_comps_related(entity: Entity, comp_parent: Script) -> Array[Component]:
	var arr_aux: Array[Component] = []
	for component in entity.components:
		if comp_inheritance(component.get_script(), comp_parent):
			arr_aux.append(component)
	return arr_aux


## Remove o componenete de um determinado tipo da entidade
static func remove_comp(entity: Entity, comp_type: Script) -> void:
	var components_to_remove: Array[Component] = []

	for component in entity.components:
		if component.get_script() == comp_type:
			components_to_remove.append(component)

	# teoricamente a lista `components_to_remove` só pode ter um item
	if components_to_remove.size() > 1:
		push_warning(
			"entity %s had more than one componente of type: %s!" % [str(entity.id), str(comp_type)]
		)

	for component in components_to_remove:
		entity.components.erase(component)


## Adiciona um componenete de determinado tipo se a entidade não tiver um daquele tipo
static func ensure_comp(entity: Entity, comp_type: Script) -> void:
	for component in entity.components:
		if component.get_script() == comp_type:
			return

	var new_component: Component = comp_type.new()
	entity.components.append(new_component)


## Checa se um componente herda de outro (indiretamente ou não)
static func comp_inheritance(component: Script, comp_parent: Script) -> bool:
	if component == comp_parent:
		return true

	if component == Component:
		return false

	return comp_inheritance(component.get_base_script(), comp_parent)

static func component_to_dict(comp: Component) -> Dictionary:
	var dict = {}
	var props = comp.get_property_list()
	for prop in props:
		var name = prop["name"]
		# Ignorar propriedades herdadas ou internas
		if (
			name.begins_with("_")
			or (
				name
				in [
					"script",
					"resource_local_to_scene",
					"resource_name",
					"resource_scene_unique_id",
					"resource_path"
				]
			)
		):
			continue

		var value = comp.get(name)
		# Converter tipos Godot para serializável
		match prop["type"]:
			TYPE_NIL:
				continue
			TYPE_VECTOR2:
				dict[name] = {"x": value.x, "y": value.y}
			TYPE_INT, TYPE_FLOAT, TYPE_STRING:
				dict[name] = value
			TYPE_BOOL:
				dict[name] = value
			_:
				# Objects complexos precisam manual
				dict[name] = str(value)
	return dict


static func from_dict_to_component(comp: Component,data: Dictionary) -> void:
	for key in data.keys():
		if key in comp:
			var value = data[key]
			if typeof(value) == TYPE_DICTIONARY and value.has("x"):
				comp.set(key, Vector2(value["x"], value["y"]))
			else:
				comp.set(key, value)
