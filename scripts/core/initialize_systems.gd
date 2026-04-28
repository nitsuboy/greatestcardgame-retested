class_name InitSystems
extends Node

static var systemRegistry: Array[Script]


static func preload_systems_recursive(path: String):
	var dir = DirAccess.open(path)
	if dir == null:
		return

	dir.list_dir_begin()
	var dir_name = dir.get_next()

	while dir_name != "":
		var full_path = path + "/" + dir_name

		if dir.current_is_dir():
			preload_systems_recursive(full_path)
		else:
			if dir_name.ends_with("system.gd"):
				var script = load(full_path)
				var system = script.new()
				if system is System:
					systemRegistry.append(script)

		dir_name = dir.get_next()


static func initialize_all_systems() -> void:
	var root = "res://scripts/game"
	preload_systems_recursive(root)

	for system in systemRegistry:
		system.initialize()
