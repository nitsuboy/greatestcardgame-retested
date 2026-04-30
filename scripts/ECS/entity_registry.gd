class_name EntityRegistry
extends RefCounted

static var next_id: int = 0
static var _all_entities: Dictionary[int,Entity] = {}


static func calculate_next_id() -> int:
	while _all_entities.has(next_id):
		next_id += 1
	return next_id


static func get_entity(id: int) -> Entity:
	return _all_entities.get(id)


static func get_all_entities() -> Dictionary:
	return _all_entities


static func delete_entity(id: int) -> bool:
	return _all_entities.erase(id)
