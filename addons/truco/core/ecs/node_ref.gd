class_name NodeRef
extends Component

var node: Node


func _init(_node: Node) -> void:
	node = _node


func should_serialize() -> bool:
	return false
