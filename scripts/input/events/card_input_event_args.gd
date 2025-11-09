class_name CardInputEventArgs
extends EventArgs

var entity: Entity
var input_event: InputEvent


func _init(_input_event: InputEvent, _entity: Entity):
	input_event = _input_event
	entity = _entity
