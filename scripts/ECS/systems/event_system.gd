class_name EventSystem
extends System

static var LocalEventComponentMethod: Dictionary[Script, ComponentMethod]

static var GlobalEventMethod: Dictionary[Script, ArrayMethod]


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

	var array_methods = GlobalEventMethod.get(event_type)

	if array_methods:
		array_methods.methods.append(method)
	else:
		GlobalEventMethod[event_type] = ArrayMethod.new()
		GlobalEventMethod[event_type].methods.append(method)


static func IniciarEventoLocal(entity: Entity, evento: Event):
	var event_type = evento.get_script()

	var compMethod = LocalEventComponentMethod.get(event_type)
	if not compMethod:
		return  # evento que nenhum componente escuta

	for component_type in compMethod:
		var comp = EntitySystem.get_comp(entity, component_type)
		if comp:
			compMethod[component_type].call(entity, comp, evento)


static func IniciarEventoGlobal(evento: Event):
	var event_type = evento.get_script()

	var array_method = GlobalEventMethod.get(event_type)
	if array_method:
		for method in array_method.methods:
			method.call(evento)


class ComponentMethod:
	var method: Dictionary[Script, Callable]


class ArrayMethod:
	var methods: Array[Callable]
