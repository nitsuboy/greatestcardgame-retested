extends Node2D

func _ready() -> void:
	var conf = Config.CarregarConfiguracoes()
	for key in conf:
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index(key),
			linear_to_db(conf[key]/100)
		)

func _on_nova_sala_btn_pressed() -> void:
	pass # Replace with function body.


func _on_convidado_btn_pressed() -> void:
	pass # Replace with function body.


func _on_config_btn_pressed() -> void:
	$Control/CenterContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer2.reload_value()
	$Control/CenterContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer3.reload_value()
	$Control/CenterContainer/Panel.visible = !$Control/CenterContainer/Panel.visible
	Config.SalvarConfiguracoes($Control/CenterContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer2.canal,$Control/CenterContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer2.volume)
	Config.SalvarConfiguracoes($Control/CenterContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer3.canal,$Control/CenterContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer3.volume)
