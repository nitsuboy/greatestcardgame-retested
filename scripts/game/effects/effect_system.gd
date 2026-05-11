class_name EffectSystem
extends SystemNode

var _turn_entity: int = -1


func init_system() -> void:
	world.events.on_card_played.connect(_on_card_played)
	world.events.on_component_added.connect(_check_turn_entity)


func _check_turn_entity(_entity: int, type: Script) -> void:
	if type == TurnComponent and _turn_entity == -1:
		_turn_entity = _entity


func _on_card_played(entity: int, played_by: int) -> void:
	if not multiplayer.is_server():
		return

	# Efeitos da própria carta jogada
	if world.has_component(entity, CardEffectsComponent):
		var effects = world.get_component(entity, CardEffectsComponent)
		for effect in effects.on_play:
			_execute(effect, entity, played_by)

	# Efeitos de OUTRAS cartas que reagem a "on_other_play"
	world.query([CardEffectsComponent]).for_each(
		func(e, comps):
			if e == entity:
				return
			var effects = comps[0] as CardEffectsComponent
			for effect in effects.on_other_play:
				_execute(effect, e, played_by)
	)


func _execute(effect: Effect, source_entity: int, played_by: int) -> void:
	if not multiplayer.is_server():
		return
	match effect.type:
		Effect.Type.DRAW:
			var target = _resolve_target(effect.target, played_by)
			Remote.send("draw_card", {"amount": effect.amount, "player": target})

		Effect.Type.SKIP:
			Remote.send("skip_turn", {"amount": effect.amount})

		Effect.Type.REVERSE:
			if world.entities.exists(_turn_entity):
				var turn = world.get_component(_turn_entity, TurnComponent)
				turn.direction *= -1
				replicator.push_state(
					[
						{
							"entity": _turn_entity,
							"type": TurnComponent.resource_path,
							"data": turn.to_dict()
						}
					],
					"reverse_%d" % source_entity
				)

		Effect.Type.WILD:
			var choice_sys = world.get_system(PlayerChoiceSystem)
			if choice_sys:
				choice_sys.request_choice(played_by, "color", {"entity": source_entity})

		_:
			push_warning("unknown effect type: ", effect.type)


func _resolve_target(target: String, played_by: int) -> int:
	match target:
		"next":
			if not world.entities.exists(_turn_entity):
				return played_by
			var turn = world.get_component(_turn_entity, TurnComponent)
			var ids = Players.get_player_ids()
			if ids.is_empty():
				return played_by
			var idx = ids.find(turn.current_player)
			if idx < 0:
				return played_by
			return ids[(idx + turn.direction + ids.size()) % ids.size()]
		"self":
			return played_by
		_:
			return played_by
