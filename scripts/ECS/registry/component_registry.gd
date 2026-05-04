class_name ComponentRegistry
extends RefCounted
#                                              Dictionary[int, Component]
static var _all_components: Dictionary[Script, Dictionary] = {}


## register a new component type to the registry
static func register_component(component_type: Script):
	if _all_components.has(component_type):
		return

	_all_components[component_type] = {}


## Return the component registry
static func get_component_registry() -> Dictionary[Script, Dictionary]:
	return _all_components


## Return all component types
static func get_all_component_types() -> Array[Script]:
	return _all_components.keys()


## adds a component to a entity in the component_registry
static func add_component_to_entity(entity_uid: int, component: Component):
	var component_type: Script = component.get_script()

	var component_type_dict: Dictionary[int, Component] = _all_components.get(component_type)
	if component_type_dict == null:
		push_error("Tentando adicionar componente de um tipo não registrado em uma entidade")
		return

	if component_type_dict.has(entity_uid):
		push_error("Tentando adicionar um componente para uma entidae que já tem um componenete daquele tipo")
		return

	component_type_dict[entity_uid] = component


## removes a component from a entity in the component_registry 
## (doesn't actually delete the component)
static func remove_component_from_entity(entity_uid: int, component_type: Script):
	var component_type_dict: Dictionary[int, Component] = _all_components.get(component_type)

	if component_type_dict == null:
		push_error("Tentando remover um tipo de componente não registrado de uma entidade")
		return

	component_type_dict.erase(entity_uid)
