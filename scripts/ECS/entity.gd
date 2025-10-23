class_name Entity

static var next_id: int = 0
static var all_entities: Array[Entity] = []

var id: int
var components: Array[Component] = []


func _init():
	id = next_id

	next_id += 1
	all_entities.append(self)

func _notification(what: int):
	if what == NOTIFICATION_PREDELETE:
		all_entities.erase(self)

static func get_all_entities() -> Array[Entity]:
	return all_entities
