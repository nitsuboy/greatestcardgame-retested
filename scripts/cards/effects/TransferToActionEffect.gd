extends Effect
class_name TransferToActionEffect


func ApplyEffect(_card: Card, _argument: Variant, _argument2: Variant) -> Variant:
	var p = _card.global_position
	var _parent = _card.get_parent()

	if _argument2 is ActionZone:
		pass

	if _argument is ActionZone:
		_parent.remove_child(_card)
		_argument.static_container.add_child(_card)

	_card.global_position = p
	_card.rotation = 0
	return null
