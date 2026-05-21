## Central event bus for the ECS and framework.
##
## All events — from ECS lifecycle (entity creation/deletion,
## component add/remove) to card interaction (input, hover,
## drop) — are emitted here.
##
## Accessed via world.events.
class_name EventBus
extends RefCounted

## Emitted when a new entity is created.
signal on_entity_created(entity: int)
## Emitted when an entity is destroyed.
signal on_entity_destroyed(entity: int)
## Emitted when a component is added to an entity.
signal on_component_added(entity: int, component_type: Script)
## Emitted when a component is removed from an entity.
signal on_component_removed(entity: int, component_type: Script)

## Emitted when the player interacts with a card (click/drag).
signal on_card_input(entity_id: int, input_event: InputEvent)
## Emitted when the mouse leaves the card area.
signal on_card_mouse_exited(entity_id: int)
## Emitted when the mouse enters the card area.
signal on_card_mouse_entered(entity_id: int)
## Emitted when a card is drawn from the deck.
signal on_card_drawn(entity_id: int, player_id: int)
## Emitted when a card is played.
signal on_card_played(entity_id: int, played_by: int)
## Emitted when a card is dropped onto a drop zone.
signal on_card_dropped(entity_id: int, dropzone: Node)
## Emitted after all card effects have been processed.
signal on_effects_completed
## Emitted when card drawing is finished.
signal on_draw_completed(player: int, amount: int, from_stack: bool)
## Emitted when the game entity is created and ready.
signal on_game_entity_ready(entity: int)
## Emitted when the game ends, indicating the winner.
signal on_game_over(winner_id: int)
