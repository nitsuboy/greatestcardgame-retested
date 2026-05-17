class_name TurnComponent
extends Component

@export var phase: int = TurnSequenceSystem.Phase.IDLE
@export var current_player: int = 1
@export var direction: int = 1
@export var turn_number: int = 0
@export var skip_amount: int = 0
