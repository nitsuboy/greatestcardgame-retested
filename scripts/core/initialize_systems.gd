class_name InitSystems
extends Node

static var system_registry: Array[Script]


static func initialize_all_systems() -> void:
	for cn in ProjectSettings.get_global_class_list():
		if cn["base"].ends_with("Component"):
			ComponentRegistry._all_components[cn["class"]] = load(cn["path"])
		if cn["base"].ends_with("System"):
			system_registry.append(load(cn["path"]))
	for system in system_registry:
		system.initialize()
