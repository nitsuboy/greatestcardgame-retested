class_name InitSystems
extends Node


static func initialize_all_systems() -> void:
	for class_ in ProjectSettings.get_global_class_list():
		var class_parent = class_["base"]
		var class_path = class_["path"]

		if class_parent.ends_with("Component"):
			ComponentRegistry.register_component(load(class_path))
		if class_parent.ends_with("System"):
			SystemRegistry.register_system(load(class_path))

	for system in SystemRegistry.get_all_systems():
		system.initialize()
