class_name EntitySystem
extends System


## Retorna verdadeiro se a entidade tem um componente de determinado tipo, falso se não
static func has_comp(entity: Entity, comp_type: Script) -> bool:
	var entity_uid = entity.uid

	var component_type_dict: Dictionary[int, Component] = ComponentRegistry.get_component_registry().get(comp_type)
	if component_type_dict == null:
		push_error("comp_type não foi registrado")
		return false

	return component_type_dict.has(entity_uid)


## Retorna o componente de determinado tipo se a entidade tiver, caso contrário retorna null
static func get_comp(entity: Entity, comp_type: Script) -> Component:
	var entity_uid = entity.uid

	var component_type_dict: Dictionary[int, Component] = ComponentRegistry.get_component_registry().get(comp_type)
	if component_type_dict == null:
		push_error("comp_type não foi registrado")
		return null

	return component_type_dict.get(entity_uid)


## Remove o componenete de um determinado tipo da entidade
static func remove_comp(entity: Entity, comp_type: Script) -> void:
	if not has_comp(entity, comp_type):
		return

	var entity_uid = entity.uid
	var comp = get_comp(entity, comp_type)
	
	var ev = ComponentRemoveEvent.new()
	EventSystem.iniciar_evento_local(entity, ev)

	ComponentRegistry.remove_component_from_entity(entity_uid, comp_type)
	comp.free()


## Adiciona um componenete de determinado tipo se a entidade não tiver um daquele tipo
## Independente se tinha ou não, retorna o componente
static func ensure_comp(entity: Entity, comp_type: Script) -> Component:
	if has_comp(entity, comp_type):
		return get_comp(entity, comp_type)

	var entity_uid = entity.uid
	var new_component: Component = comp_type.new()
	ComponentRegistry.add_component_to_entity(entity_uid, new_component)
	
	var ev = ComponentInitEvent.new()
	EventSystem.iniciar_evento_local(entity, ev)

	return new_component


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


static func from_dict_to_component(comp: Component, data: Dictionary) -> void:
	for key in data.keys():
		if key in comp:
			var value = data[key]
			if typeof(value) == TYPE_DICTIONARY and value.has("x"):
				comp.set(key, Vector2(value["x"], value["y"]))
			else:
				comp.set(key, value)
