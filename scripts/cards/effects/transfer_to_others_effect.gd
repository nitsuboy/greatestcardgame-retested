class_name TransferToOthersEffect
extends Effect


func apply_effect(_card: Card, _argument: Variant, _argument2: Variant) -> Variant:
	var p = _card.global_position
	var parent = _card.get_parent()

	if (_argument is Player) and (_argument2 != _argument) and _argument != _card.holder:
		_card.holder = _argument
		parent.remove_child(_card)
		_argument.hand.add_child(_card)
		_card.global_position = p
		_card.rotation = 0

	return null
