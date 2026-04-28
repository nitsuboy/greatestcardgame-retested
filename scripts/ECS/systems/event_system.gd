class_name EventSystem
extends System

static var local_event_component_method: Dictionary[Script, ComponentMethod]

static var global_event_method: Dictionary[Script, ArrayMethod]


static func inscrever_evento_local(
	component_type: Script, event_type: Script, method: Callable
) -> void:
	var comp_method
	if local_event_component_method.has(event_type):
		comp_method = local_event_component_method[event_type]
	else:
		comp_method = ComponentMethod.new()

	if comp_method.method.has(component_type):
		push_error("tentando inscrever mais de um método em uma combinação evento-componente")
		return
	comp_method.method[component_type] = method


static func inscrever_evento_global(event_type: Script, method: Callable) -> void:
	var array_methods = global_event_method.get(event_type)

	if array_methods:
		array_methods.methods.append(method)
	else:
		global_event_method[event_type] = ArrayMethod.new()
		global_event_method[event_type].methods.append(method)


static func iniciar_evento_local(entity: Entity, evento: Event):
	var event_type = evento.get_script()

	var comp_method = local_event_component_method.get(event_type)
	if not comp_method:
		return  # evento que nenhum componente escuta

	for component_type in comp_method:
		var comp = EntitySystem.get_comp(entity, component_type)
		if comp:
			comp_method[component_type].call(entity, comp, evento)


static func iniciar_evento_global(evento: Event):
	var event_type = evento.get_script()

	var array_method = global_event_method.get(event_type)
	if array_method:
		for method in array_method.methods:
			method.call(evento)


class ComponentMethod:
	var method: Dictionary[Script, Callable]


class ArrayMethod:
	var methods: Array[Callable]
