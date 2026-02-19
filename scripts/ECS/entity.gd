class_name Entity

static var next_id: int = 0
static var all_entities: Dictionary[int,Entity] = {}

var id: int
var components: Array[Component] = []


func _init(_id: int = -1):
	if Globals.debug or (_id == -1 and NetworkManager.multiplayer.is_server()):
		id = next_id
		next_id += 1
	else:
		id = _id
	all_entities[id] = self


func _notification(what: int):
	if what == NOTIFICATION_PREDELETE:
		all_entities.erase(self)
