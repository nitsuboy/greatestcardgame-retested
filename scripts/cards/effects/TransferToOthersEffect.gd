extends Effect
class_name TransferToOthersEffect

func ApplyEffect(_card: Card,_argument: Variant) -> Variant:
	var p = _card.global_position
	var _parent = _card.get_parent()
	
	if (_argument is Player) and (_parent.get_parent() != _argument) and _argument != _card.holder:
		_card.holder = _argument
		_parent.remove_child(_card)
		_argument.hand.add_child(_card)
		_card.global_position = p
		_card.rotation = 0

	return null
