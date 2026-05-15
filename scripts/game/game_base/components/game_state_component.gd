class_name GameStateComponent
extends Component

var zones: Dictionary = {}


func get_cards_in_zone(zone_id: int) -> Array:
	return zones.get(zone_id, [])


func get_top_card(zone_id: int) -> int:
	var cards = zones.get(zone_id, [])
	return cards[-1] if cards else -1


func rebuild(world: World) -> void:
	zones.clear()
	var storage = world.get_storage(CardComponent)
	if not storage:
		return
	var ents = storage.get_all_entities()
	var data = storage.get_all_data()
	for i in ents.size():
		var card = data[i] as CardComponent
		if not card:
			continue
		var zid = card.zone_id
		if not zones.has(zid):
			zones[zid] = []
		zones[zid].append({"entity": ents[i], "order": card.play_order})
	for zid in zones.keys():
		zones[zid].sort_custom(func(a, b): return a.order < b.order)
		var ids: Array[int] = []
		for e in zones[zid]:
			ids.append(e.entity)
		zones[zid] = ids
