extends VBoxContainer


func _on_control_cartaposta(carta: Variant) -> void:
	if carta.get_parent() == self:
		return
	carta.get_parent().remove_child(carta)
	add_child(carta)
