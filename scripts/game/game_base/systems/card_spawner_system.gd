class_name CardSpawnerSystem
extends SystemNode

@export var card_scene: PackedScene


func init_system() -> void:
	world.events.on_component_added.connect(_on_component_added)


func _on_component_added(entity: int, type: Script) -> void:
	if type != CardComponent:
		return
	if world.has_component(entity, NodeRef):
		return

	var card_comp = world.get_component(entity, CardComponent) as CardComponent
	if not card_comp:
		return

	var card_node: Control = card_scene.instantiate()
	card_node.entity_id = entity
	card_node.world = world

	var ref = NodeRef.new(card_node)
	world.add_component(entity, ref)

	var parent = _get_zone_parent(card_comp.zone_id)
	if parent:
		parent.add_child(card_node)
		if card_node.has_method("post_instantiate"):
			card_node.post_instantiate(world, entity)

	card_node.gui_input.connect(func(event): world.events.on_card_input.emit(entity, event))
	card_node.mouse_exited.connect(func(): world.events.on_card_mouse_exited.emit(entity))


func _get_zone_parent(zone_id: int) -> Node:
	match zone_id:
		1:
			return get_tree().get_first_node_in_group("player1_hand")
		2:
			return get_tree().get_first_node_in_group("player2_hand")
		999:
			return get_tree().get_first_node_in_group("play_zone")
		1000:
			return get_tree().get_first_node_in_group("discard_zone")
		_:
			return get_tree().get_first_node_in_group("player_hand")
