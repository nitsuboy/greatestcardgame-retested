class_name TransferToQuestionEffect
extends Effect

@export var answer: int = 0


func apply_effect(_card: Card, _from: Variant, _to: Variant) -> Variant:
	var p = _card.global_position
	var parent = _card.get_parent()

	if _from is QuestionZone:
		_from.answers[answer] -= 1
		_card.holder.tests_left += 1

	if _to is QuestionZone and (_card.holder.tests_left > 0):
		parent.remove_child(_card)
		_to.static_container.add_child(_card)
		_to.answers[answer] += 1
		_card.holder.tests_left -= 1

	_card.global_position = p
	_card.rotation = 0
	return null
