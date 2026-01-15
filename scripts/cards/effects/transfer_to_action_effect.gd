class_name TransferToActionEffect
extends Effect


func apply_effect(_card: Card, _from: Variant, _to: Variant) -> Variant:
	var p = _card.global_position
	var parent = _card.get_parent()

	if _from != _to:
		if (_to is Player) and _to == _card.holder:
			if _card.holder.tests_left > 0:
				parent.remove_child(_card)
				_to.hand.add_child(_card)
				_card.global_position = p
				_card.rotation = 0
			else:
				var comp = EntitySystem.get_comp(_card.entity, DraggableComponent)
				DragSystem.lock_drag(comp, _card)
				await _card.shake_negation()
				DragSystem.unlock_drag(comp, _card)
				return

			if _from is ActionZone:
				if _card.holder.tests_left > 0:
					_card.holder.tests_left -= 1

		if _to is ActionZone:
			parent.remove_child(_card)
			_card.holder.tests_left += 1
			_to.static_container.add_child(_card)

	_card.global_position = p
	_card.rotation = 0
	return null
