extends Effect
class_name TEffect


func ApplyEffect(_card: Card, _argument: Variant) -> Variant:
	if _argument is Player:
		var p = _card.global_position
		_card.get_parent().RemoveCard(_card)
		_argument.hand.AddCard(_card)
		_card.global_position = p
	return null
