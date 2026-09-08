## Marks an entity as currently locked.
## Does not serialize (should_serialize -> false), it's only local state.
class_name LockState
extends Component


func should_serialize() -> bool:
	return false