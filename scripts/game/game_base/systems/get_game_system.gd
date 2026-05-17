class_name GetGameSystem
extends SystemNode


func init_system() -> void:
	world.events.on_component_added.connect(_on_component_added)


func _on_component_added(entity: int, component_type: Script) -> void:
	if component_type == TurnComponent:
		world.events.on_game_entity_ready.emit(entity)
		world.events.on_component_added.disconnect(_on_component_added)
