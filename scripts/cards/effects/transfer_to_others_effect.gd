class_name TransferToOthersEffect
extends Effect


func apply_effect(_card: Card, _from: Variant, _to: Variant) -> Variant:
	var p = _card.global_position
	var parent = _card.get_parent()

	if (_to is Player) and (_from != _to) and _to != _card.holder:
		_card.holder = _to
		parent.remove_child(_card)
		_to.hand.add_child(_card)
		_card.global_position = p
		_card.rotation = 0

	return null
