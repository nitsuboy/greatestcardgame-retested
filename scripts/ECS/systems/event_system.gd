class_name EventSystem
extends System

static var local_event_component_method: Dictionary[Script, Dictionary]

static var global_event_method: Dictionary[Script, Array]


## Inscreve um componente em um evento com um método.
## quando um evento daquele tipo for iniciado em uma entidade que tem aquele componente,
## o método especificado vai ser chamado
## com entidade, componente e evento como parametros, respectivamente
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


## Inscreve um método em um evento.
## quando um evento daquele tipo for iniciado globalmente, o método vai ser chamado
## com o evento como parametro
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


## inicia um evento de forma local (em uma entidade),
## chamando métodos que foram inscritos por [EventSystem.inscrever_evento_local]
## naquela entidade
static func iniciar_evento_local(entity: Entity, event: Event) -> void:
	var event_type = event.get_script()
	print("card inicialização de evento ok")
	_processar_evento_local(entity, event, event_type)


static func _processar_evento_local(entity: Entity, event: Event, event_type: Script) -> void:
	print("card processar evento ok 1")
	if event_type != null and event_type != Event:  # se não é Event, então deve herdar de Event
		# roda a mesma função considerando o evento como sendo o tipo do pai
		# para que um evento A que herda de B ainda chame métodos associados com B
		_processar_evento_local(entity, event, event_type.get_base_script())

	# nenhuma entrada para o evento, logo,
	# nenhum componente escuta aquele tipo de evento especifico
	if not local_event_component_method.has(event_type):
		return
	print("card processar evento ok 2")

	# dicionário de funções (chaves são Script de componentes)
	var comp_method = local_event_component_method[event_type]
	print(comp_method)

	# para cada tipo de componente do dicionário
	for component_type in comp_method.keys():
		print(component_type)
		# tentar obter o componente da entidade
		var comp = EntitySystem.get_comp(entity, component_type)
		print(comp)
		if comp:  # se tiver, chama a função
			comp_method[component_type].call(entity, comp, event)
			print("card processar evento ok 3")


## inicia um evento de forma global,
## chamando métodos que foram inscritos por [EventSystem.inscrever_evento_global]
static func iniciar_evento_global(event: Event) -> void:
	var event_type = event.get_script()
	_processar_evento_global(event, event_type)


static func _processar_evento_global(event: Event, event_type: Script) -> void:
	if event_type != null and event_type != Event:  # se não é Event, então deve herdar de Event
		# roda a mesma função considerando o evento como sendo o tipo do pai
		# para que um evento A que herda de B ainda chame métodos associados com B
		_processar_evento_global(event, event_type.get_base_script())

	# nenhuma entrada para o evento, logo,
	# nenhum método para chamar
	if not global_event_method.has(event_type):
		return

	# para cada método do array
	for method in global_event_method[event_type]:
		method.call(event)  # chama a função
