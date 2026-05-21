## Player data component.
## Stores peer_id, hand zone, ready state, and whether it's a bot.
class_name PlayerComponent
extends Component

## Player's peer ID on the network.
@export var peer_id: int = 0
## Zone ID representing this player's hand.
@export var hand_zone_id: int = 0
## Whether the player is ready (lobby).
@export var ready: bool = false
## Whether this player is AI-controlled.
@export var is_bot: bool = false
