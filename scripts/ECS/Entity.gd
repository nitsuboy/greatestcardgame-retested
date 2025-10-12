class_name Entity

static var next_id: int = 0

var id: int
var components: Array[Component]

func _init():
    id = next_id
    next_id += 1
    components = []
