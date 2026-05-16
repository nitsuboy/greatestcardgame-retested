# ecs/event_bus.gd
class_name EventBus
extends RefCounted

# ECS signals
signal on_entity_created(entity: int)
signal on_entity_destroyed(entity: int)
signal on_component_added(entity: int, component_type: Script)
signal on_component_removed(entity: int, component_type: Script)

# Game signals
# Input
signal on_card_input(entity_id: int, input_event: InputEvent)
signal on_card_mouse_exited(entity_id: int)
signal on_card_mouse_entered(entity_id: int)
# Frame
signal on_frame_start(delta: float)
signal on_frame_end(delta: float)
# Cards
signal on_card_drawn(entity_id: int, player_id: int)
signal on_card_played(entity_id: int, played_by: int)
signal on_card_dropped(entity_id: int, dropzone: Node)
# Turn
signal on_turn_changed(current_player: int, turn_number: int)
signal on_effects_completed
signal on_draw_completed(player: int, amount: int, from_stack: bool)
# Game over
signal on_game_over(winner_id: int)
