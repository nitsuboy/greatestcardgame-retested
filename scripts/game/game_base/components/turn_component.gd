class_name TurnComponent
extends Component

enum Phase {
	IDLE = 0, TURN_START, STACK_RESOLUTION, PLAYER_ACTION, EFFECT_RESOLUTION, POST_DRAW, TURN_END
}

@export var phase: int = Phase.IDLE
@export var current_player: int = 1
@export var direction: int = 1
@export var turn_number: int = 0
@export var skip_amount: int = 0
