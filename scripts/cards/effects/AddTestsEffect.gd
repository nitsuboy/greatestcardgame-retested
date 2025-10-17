extends Effect
class_name AddTestsEffect

@export var tests: int = 2


func ApplyEffect(_card: Card, _argument: Variant, _argument2: Variant) -> Variant:
	var p = _card.global_position
	var _parent = _card.get_parent()

	if _argument2 is ActionZone:
		_card.holder.AddTests(-tests)

	if _argument is ActionZone:
		_parent.remove_child(_card)
		_argument.static_container.add_child(_card)
		_card.holder.AddTests(tests)

	_card.global_position = p
	_card.rotation = 0
	return null
