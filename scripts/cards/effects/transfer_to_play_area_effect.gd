class_name TransferToPlayEffect
extends Effect


func apply_effect(_card: Card, _from: Variant, _to: Variant) -> Variant:
	var p = _card.global_position
	var parent = _card.get_parent()

	if _from != _to:
		if (_to is Player) and _to == _card.holder:
			parent.remove_child(_card)
			_to.hand.add_child(_card)
			_card.global_position = p
			_card.rotation = 0
		if _to is PlayZone:
			parent.remove_child(_card)
			_to.static_container.add_child(_card)
			_to.emit_play()

	_card.global_position = p
	_card.rotation = 0
	return null
