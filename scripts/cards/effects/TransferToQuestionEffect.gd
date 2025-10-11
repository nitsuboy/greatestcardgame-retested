extends Effect
class_name TransferToQuestionEffect

@export var answer:int = 0

func ApplyEffect(_card: Card,_argument: Variant) -> Variant:
	var p = _card.global_position
	var _parent = _card.get_parent()
	
	if _parent.get_parent() is QuestionZone:
		_parent.get_parent().answers[answer] -= 1
	
	if _argument is QuestionZone:
		_parent.remove_child(_card)
		_argument.static_container.add_child(_card)
		_argument.answers[answer] += 1
	
	_card.global_position = p
	_card.rotation = 0
	return null
