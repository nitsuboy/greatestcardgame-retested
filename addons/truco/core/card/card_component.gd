## Universal card component.
##
## Identifies an entity as a card with zone, orientation,
## and play order. Present on every card in the system.
class_name CardComponent
extends Component

## ID of the zone where the card is (hand, discard, deck).
@export var zone_id: int = 0
## Whether the card is face up.
@export var face_up: bool = false
## Play order (for sequence reconstruction).
@export var play_order: int = 0
