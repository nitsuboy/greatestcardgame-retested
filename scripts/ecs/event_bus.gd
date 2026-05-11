# ecs/event_bus.gd
class_name EventBus
extends RefCounted

# ECS signals
signal on_entity_created(entity: int)
signal on_entity_destroyed(entity: int)
signal on_component_added(entity: int, component_type: Script)
signal on_component_removed(entity: int, component_type: Script)

# Game signals
signal on_card_input(entity_id: int, input_event: InputEvent)
signal on_card_mouse_exited(entity_id: int)
signal on_frame_start(delta: float)
signal on_frame_end(delta: float)
signal on_card_drawn(entity_id: int, player_id: int)
signal on_card_played(entity_id: int, played_by: int)
signal on_card_dropped(entity_id: int, dropzone: Node)
