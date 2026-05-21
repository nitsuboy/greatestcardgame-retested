## Automatically instantiates card visuals when
## a CardComponent is added to an entity.
##
## Creates a NodeRef pointing to the instantiated visual and
## adds it to the corresponding zone (via ZoneRegistry).
class_name CardSpawnerSystem
extends SystemNode

## Card visual scene to instantiate.
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

	var parent: DropZone = Zones.get_zone(card_comp.zone_id)
	if parent:
		parent.add_card(card_node)
		if card_node.has_method("post_instantiate"):
			card_node.post_instantiate(world, entity)
