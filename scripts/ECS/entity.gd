class_name Entity

static var next_id: int = 0
static var all_entities: Dictionary[int,Entity] = {}

var id: int
var components: Array[Component] = []


func _init(_id: int = -1):
	if Globals.debug or (_id == -1 and NetworkManager.multiplayer.is_server()):
		while all_entities.has(next_id):
			next_id += 1
		id = next_id
		next_id += 1
		all_entities[id] = self
	elif _id > -1:
		id = _id
		all_entities[id] = self


func _notification(what: int):
	if what == NOTIFICATION_PREDELETE:
		print("sayonara")
