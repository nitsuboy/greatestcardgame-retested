## Marks an entity as currently being dragged.
## Does not serialize (should_serialize → false), it's only local state.
class_name DragState
extends Component


func should_serialize() -> bool:
	return false
