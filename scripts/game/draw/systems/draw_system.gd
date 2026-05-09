class_name DrawSystem
extends SystemNode


# Server-side: pega carta do deck e retorna dict serializável
func draw_single_card_data(world: World) -> Dictionary:
	var dealer = _get_dealer()
	if not dealer:
		return {}

	var card_data: CardData = dealer.deck.draw()
	if not card_data:
		return {}

	var entity_id = world.create_entity()
	return {
		"entity_id": entity_id,
		"id": card_data.id,
		"name": card_data.card_name,
		"value": card_data.card_value,
		"color": card_data.card_color,
		"components": _serialize_components(card_data.components)
	}


# Client/server: instancia a carta e adiciona à mão
func draw_single_card(world: World, player_id: int, card_dict: Dictionary) -> void:
	var dealer = _get_dealer()
	if not dealer:
		return

	var card: Card
	if Net.multiplayer.is_server():
		card = dealer.draw_card(card_dict["id"], card_dict["entity_id"])
	else:
		card = dealer.make_card_from_dict(card_dict)

	if not card:
		return

	card.entity_id = card_dict["entity_id"]
	card._world = world

	var player_entity = Net.game.get_player_entity(player_id)
	var player_comp: PlayerComponent = world.get_component(player_entity, PlayerComponent)

	player_comp.hand.add_card(card)
	if player_id != Net.multiplayer.get_unique_id():
		card.flip(true)

	world.events.on_card_drawn.emit(card.entity_id, player_id)


func _serialize_components(comps: Array) -> Array:
	var result = []
	for c in comps:
		if c is TriggerOnComponent or c is OnTriggerComponent:
			continue  # trigger components são removidos dos dados
		result.append({"type": c.get_script().get_global_name(), "data": _comp_to_dict(c)})
	return result


func _comp_to_dict(comp: Resource) -> Dictionary:
	var dict = {}
	for prop in comp.get_property_list():
		var name = prop["name"]
		if (
			name
			in [
				"script",
				"resource_local_to_scene",
				"resource_name",
				"resource_scene_unique_id",
				"resource_path"
			]
		):
			continue
		if name.begins_with("_"):
			continue
		dict[name] = comp.get(name)
	return dict


func _get_dealer() -> Dealer:
	return Net.game.get_dealer() if Net.game else null
