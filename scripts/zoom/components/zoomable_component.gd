class_name ZoomableComponent
extends Component

func _init() -> void:
	set_meta("cursor",true)

var zoom: float = 1.5
var cursor_shape: int = Control.CURSOR_HELP
