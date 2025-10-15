class_name Entity

static var next_id : int = 0
static var all_entities : Array[Entity] = []

var id: int
var components: Array[Component]

func _init():
	id = next_id
	next_id += 1
	components = []
	
	all_entities.append(self)

static func get_all_entities() -> Array[Entity]:
	return all_entities
