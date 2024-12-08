extends HBoxContainer

@export var canal:String

var canal_idx:int

func _ready() -> void:
	canal_idx = AudioServer.get_bus_index(canal)
	$HSlider.value_changed.connect(_on_value_changed_slider)
	$SpinBox.value_changed.connect(_on_value_changed_spin)

func _on_value_changed_slider(value:float) -> void:
	AudioServer.set_bus_volume_db(
		canal_idx,
		linear_to_db(value/100)
	)
	$SpinBox.set_value_no_signal(value)
	
func _on_value_changed_spin(value:float) -> void:
	AudioServer.set_bus_volume_db(
		canal_idx,
		linear_to_db(value/100)
	)
	$HSlider.set_value_no_signal(value)
