class_name EventSystem
extends System

static var LocalEventComponentMethod: Dictionary[Script, ComponentMethod]

static var GlobalEventMethod: Dictionary[Script, Callable]


static func InscreverEventoLocal(
	component_type: Script, event_type: Script, method: Callable
) -> void:
	var comp = component_type.new()
	if not (comp is Component):
		push_error("componente deve ser um script de Component")
		return

	var event = event_type.new()
	if not (event is Event):
		push_error("evento deve ser um script de Event")
		return

	var compMethod
	if LocalEventComponentMethod.has(event_type):
		compMethod = LocalEventComponentMethod[event_type]
	else:
		compMethod = ComponentMethod.new()

	if compMethod.has(component_type):
		push_error("tentando inscrever mais de um método em uma combinação evento-componente")
		return
	else:
		compMethod[component_type] = method


static func InscreverEventoGlobal(event_type: Script, method: Callable) -> void:
	var event = event_type.new()
	if not (event is Event):
		push_error("evento deve ser um script de Event")
		return

	if GlobalEventMethod.has(event_type):
		push_error("tentando inscrever mais de um método em um evento")
		return

	GlobalEventMethod[event_type] = method


static func IniciarEventoLocal(entity: Entity, evento: Event):
	var event_type = evento.get_script()

	if not LocalEventComponentMethod.has(event_type):
		return  # evento que nenhum componente escuta

	var compMethod = LocalEventComponentMethod[event_type]
	for component_type in compMethod:
		var comp = EntitySystem.get_comp(entity, component_type)
		if comp:
			compMethod[component_type].call(entity, comp, evento)


static func IniciarEventoGlobal(evento: Event):
	var event_type = evento.get_script()

	if not GlobalEventMethod.has(event_type):
		return  # evento que nenhum sistema escuta

	GlobalEventMethod[event_type].call(evento)


class ComponentMethod:
	var method: Dictionary[Script, Callable]
