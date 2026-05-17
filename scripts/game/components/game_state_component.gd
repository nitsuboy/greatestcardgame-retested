class_name GameStateComponent
extends Component

var zones: Dictionary = {}
var _entity_zone: Dictionary = {}  # entity_id → zone_id (cache para remoção O(1))


func get_cards_in_zone(zone_id: int) -> Array:
	return zones.get(zone_id, [])


func get_top_card(zone_id: int) -> int:
	var cards = zones.get(zone_id, [])
	return cards[-1] if cards else -1


# --- NOVO: atualização incremental (O(k), k = cartas no batch) ---
func apply_batch(batch: Array[Dictionary]) -> void:
	for entry in batch:
		if entry.type != CardComponent.resource_path:
			continue
		var eid: int = entry.entity
		var new_zone: int = entry.data.get("zone_id", -1)

		# Remove da zona antiga (se existir)
		if _entity_zone.has(eid):
			var old_zone = _entity_zone[eid]
			if zones.has(old_zone):
				var arr: Array = zones[old_zone]
				var idx = arr.find(eid)
				if idx >= 0:
					arr.remove_at(idx)
				if arr.is_empty():
					zones.erase(old_zone)

		# Adiciona na nova zona
		if not zones.has(new_zone):
			zones[new_zone] = []
		zones[new_zone].append(eid)
		_entity_zone[eid] = new_zone


# --- Mantido para setup inicial (só roda uma vez) ---
func rebuild(world: World) -> void:
	zones.clear()
	_entity_zone.clear()
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
		zones[zid].append(ents[i])
		_entity_zone[ents[i]] = zid
	for zid in zones.keys():
		var arr = zones[zid]
		arr.sort_custom(
			func(a, b):
				return (
					(world.get_component(a, CardComponent) as CardComponent).play_order
					< (world.get_component(b, CardComponent) as CardComponent).play_order
				)
		)
