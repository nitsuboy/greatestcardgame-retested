# scripts/core/script_cache.gd (simples, pode ser autoload ou estático)
class_name ScriptCache
static var _cache: Dictionary = {}


static func get_path(type: Script) -> String:
	if not _cache.has(type):
		_cache[type] = type.resource_path
	return _cache[type]
