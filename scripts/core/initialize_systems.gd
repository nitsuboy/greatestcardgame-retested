class_name InitSystems
extends Node


static func initialize_all_systems() -> void:
	for _class in ProjectSettings.get_global_class_list():
		var class_parent = _class["base"]
		var class_type = _class["class"]
		var class_path = _class["path"]

		if class_parent.ends_with("Component"):
			ComponentRegistry.register_component(load(class_path), class_type)
		if class_parent.ends_with("System"):
			SystemRegistry.register_system(load(class_path))

	for system in SystemRegistry.get_all_systems():
		system.initialize()
