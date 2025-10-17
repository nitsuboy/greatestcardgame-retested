extends CardComponent
class_name PlayableComponent


func on_drop(_card: Card, _dropzone: Node) -> void:
	if _dropzone and _dropzone is DropZone:
		for effect in _card.card_data.effects:
			effect.ApplyEffect(_card, _dropzone.who_to_apply)
