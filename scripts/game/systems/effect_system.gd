class_name EffectSystem
extends SystemNode

var _game_entity: int = -1
var _pending_wild: Dictionary = {}  # request_id → {source_entity, played_by}


func init_system() -> void:
	world.events.on_game_entity_ready.connect(func(e): _game_entity = e)
	world.events.on_card_played.connect(_on_card_played)
	var choice_sys = world.get_system(PlayerChoiceSystem)
	if choice_sys:
		choice_sys.choice_received.connect(_on_choice_received)


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

	if _pending_wild.is_empty():
		world.events.on_effects_completed.emit()


func _execute(effect: Effect, source_entity: int, played_by: int) -> void:
	if not multiplayer.is_server():
		return
	match effect.type:
		Effect.Type.DRAW:
			if world.entities.exists(_game_entity):
				var stack = (
					world.get_component(_game_entity, DrawStackComponent) as DrawStackComponent
				)
				if stack:
					stack.accumulated += effect.amount
					replicator.push_state(
						[
							{
								"entity": _game_entity,
								"type": DrawStackComponent.resource_path,
								"data": stack.to_dict()
							}
						],
						"stack_%d" % source_entity
					)

		Effect.Type.SKIP:
			if world.entities.exists(_game_entity):
				var turn = world.get_component(_game_entity, TurnComponent) as TurnComponent
				if turn:
					turn.skip_amount += effect.amount
					replicator.push_state(
						[
							{
								"entity": _game_entity,
								"type": TurnComponent.resource_path,
								"data": turn.to_dict()
							}
						],
						"skip_%d" % source_entity
					)

		Effect.Type.REVERSE:
			if world.entities.exists(_game_entity):
				var turn = world.get_component(_game_entity, TurnComponent)
				turn.direction *= -1
				replicator.push_state(
					[
						{
							"entity": _game_entity,
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
				_pending_wild = {"source_entity": source_entity, "played_by": played_by}
		_:
			push_warning("unknown effect type: ", effect.type)


func _on_choice_received(_sender: int, _request_id: String, choice: Variant) -> void:
	if _pending_wild.is_empty():
		return
	var uno_comp = world.get_component(_pending_wild.source_entity, UnoCardComponent)
	if not uno_comp:
		_pending_wild = {}
		return
	uno_comp.color = choice
	replicator.push_state(
		[
			{
				"entity": _pending_wild.source_entity,
				"type": UnoCardComponent.resource_path,
				"data": uno_comp.to_dict()
			}
		],
		"wild_color_%d" % _pending_wild.source_entity
	)
	_pending_wild = {}
	world.events.on_effects_completed.emit()


func _resolve_target(target: String, played_by: int) -> int:
	match target:
		"next":
			if not world.entities.exists(_game_entity):
				return played_by
			var turn = world.get_component(_game_entity, TurnComponent)
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
