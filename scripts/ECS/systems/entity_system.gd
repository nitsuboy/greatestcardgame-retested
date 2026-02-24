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
