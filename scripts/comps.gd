extends RichTextLabel

@export var wrl: WorldRunner


func _process(_delta: float) -> void:
	var wr = wrl
	if not wr or not wr.world:
		return
	text = ""
	_dump(wr.world)


func _dump(w: World) -> void:
	# Agrupa componentes por entidade
	var map: Dictionary = {}  # entity → [comp1, comp2, ...]
	for type in w._storages:
		var ss: SparseSet = w._storages[type]
		var ents = ss.get_all_entities()
		var data = ss.get_all_data()
		for i in ents.size():
			var eid = ents[i]
			if not map.has(eid):
				map[eid] = []
			var label = type.resource_path.get_file().replace(".gd", "")
			if data[i].has_method("to_dict"):
				label += " " + str(data[i].to_dict())
			map[eid].append(label)

	for eid in map.keys():
		append_text("[b]Entity %d[/b]\n" % eid)
		for label in map[eid]:
			append_text("  %s\n" % label)
