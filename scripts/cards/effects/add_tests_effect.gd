class_name AddTestsEffect
extends Effect

@export var tests: int = 2


func apply_effect(_card: Card, _from: Variant, _to: Variant) -> Variant:
	var p = _card.global_position
	var parent = _card.get_parent()

	if _from is ActionZone:
		_card.holder.add_tests(-tests)

	if _to is ActionZone:
		parent.remove_child(_card)
		_to.static_container.add_child(_card)
		_card.holder.add_tests(tests)

	_card.global_position = p
	_card.rotation = 0
	return null
