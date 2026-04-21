class_name Entity
extends RefCounted

static var next_id: int = 0
static var _all_entities: Dictionary[int,Entity] = {}

var id: int
var components: Array[Component] = []


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

func _init(_id: int = -1) -> void:
	if Globals.debug or (_id == -1 and NetworkManager.multiplayer.is_server()):
		calculate_next_id()
		id = next_id
		next_id += 1
		_all_entities[id] = self
	elif _id > -1:
		id = _id
		_all_entities[id] = self


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		print("sayonara")
