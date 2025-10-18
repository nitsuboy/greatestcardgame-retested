class_name PlayableComponent
extends CardComponent


func on_drop(_card: Card, _dropzone: Node) -> void:
	var sp = _card.get_parent().get_parent()
	if _dropzone and _dropzone is DropZone:
		for effect in _card.card_data.effects:
			effect.apply_effect(_card, _dropzone.who_to_apply, sp)
