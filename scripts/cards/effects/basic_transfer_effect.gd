class_name TEffect
extends Effect


func apply_effect(_card: Card, _to: Variant, _from: Variant) -> Variant:
	if _to is Player:
		var p = _card.global_position
		_card.get_parent().RemoveCard(_card)
		_to.hand.AddCard(_card)
		_card.global_position = p
	return null
