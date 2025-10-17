class_name PlayableComponent
extends CardComponent



func on_drop(_card: Card, _dropzone: Node) -> void:
	var sp = _card.get_parent().get_parent()
	if _dropzone and _dropzone is DropZone:
		for effect in _card.card_data.effects:
<<<<<<< HEAD:scripts/cards/components/PlayableComponent.gd
			effect.ApplyEffect(_card, _dropzone.who_to_apply, sp)
=======
			effect.apply_effect(_card, _dropzone.who_to_apply, sp)
>>>>>>> proto-base:scripts/cards/components/playable_component.gd
