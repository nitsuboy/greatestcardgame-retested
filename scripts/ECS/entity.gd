class_name Entity
extends RefCounted

var id: int
var components: Array[Component] = []


func _init(_id: int = -1) -> void:
	if Globals.debug or (_id == -1 and Net.multiplayer.is_server()):
		EntityRegistry.calculate_next_id()
		id = EntityRegistry.next_id
		EntityRegistry.next_id += 1
		EntityRegistry._all_entities[id] = self
	elif _id > -1:
		id = _id
		EntityRegistry._all_entities[id] = self


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		print("sayonara")
