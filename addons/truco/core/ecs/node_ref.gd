## Pointer to a visual Node in the scene tree.
##
## Stores a direct Node reference. Does not serialize (should_serialize
## returns false) because object references are not meaningful over the
## network. Used by CardSpawnerSystem to link entities to visuals.
class_name NodeRef
extends Component

## Reference to the visual Node.
var node: Node


func _init(_node: Node) -> void:
	node = _node


func should_serialize() -> bool:
	return false
