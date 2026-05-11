class_name Effect
extends Component

enum Type { DRAW, SKIP, REVERSE, WILD, CHANGE_COLOR, STEAL_CARD, SWAP_HANDS, DRAW_RESPONSE }

@export var type: Type
@export var amount: int = 0
@export var target: String = "next"
