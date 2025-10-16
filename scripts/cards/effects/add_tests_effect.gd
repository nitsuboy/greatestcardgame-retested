class_name AddTestsEffect
extends Effect

@export var tests: int = 2


func apply_effect(_card: Card, _argument: Variant, _argument2: Variant) -> Variant:
	var p = _card.global_position
	var parent = _card.get_parent()

	if _argument2 is ActionZone:
		_card.holder.add_tests(-tests)

	if _argument is ActionZone:
		parent.remove_child(_card)
		_argument.static_container.add_child(_card)
		_card.holder.add_tests(tests)

	_card.global_position = p
	_card.rotation = 0
	return null
