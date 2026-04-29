class_name EventSystem
extends System

static var local_event_component_method: Dictionary[Script, Dictionary]

static var global_event_method: Dictionary[Script, Array]


static func inscrever_evento_local(
	component_type: Script, event_type: Script, method: Callable
) -> void:
	print("=== EventSystem: inscrever_evento_local ===")
	print("component_type: %s" % component_type.get_global_name())
	print("event_type: %s" % event_type.get_global_name())
	print("method: %s" % method.get_method())

	if not local_event_component_method.has(event_type):
		print("primeira inscrição local do evento")
		local_event_component_method[event_type] = {}

	var comp_dict = local_event_component_method[event_type]

	if comp_dict.has(component_type):
		push_error("tentando inscrever mais de um método em uma combinação evento-componente")
		return
	comp_dict[component_type] = method
	
	print("número funções inscritas no evento: %d" % comp_dict.size())

	print("função inscrita no evento local")
	print("===========================================")


static func inscrever_evento_global(event_type: Script, method: Callable) -> void:
	print("=== EventSystem: inscrever_evento_global ===")
	print("event_type: %s" % event_type.get_global_name())
	print("method: %s" % method.get_method())

	if not global_event_method.has(event_type):
		print("primeira inscrição global do evento")
		global_event_method[event_type] = []

	var array_methods = global_event_method[event_type]
	array_methods.append(method)

	print("número funções inscritas no evento: %d" % array_methods.size())

	print("função inscrita no evento global")
	print("============================================")


static func iniciar_evento_local(entity: Entity, evento: Event):
	var event_type = evento.get_script()

	if not local_event_component_method.has(event_type):
		return

	var comp_method = local_event_component_method[event_type]

	for component_type in comp_method.keys():
		var comp = EntitySystem.get_comp(entity, component_type)
		if comp:
			comp_method[component_type].call(entity, comp, evento)


static func iniciar_evento_global(evento: Event):
	var event_type = evento.get_script()

	if not global_event_method.has(event_type):
		return

	for method in global_event_method[event_type]:
		method.call(evento)
