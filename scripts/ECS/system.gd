@abstract class_name System

static var systemRegistry: Array[Script] = []

static func register(system : Script) -> void:
	systemRegistry.append(system)

static func initialize():
	pass
