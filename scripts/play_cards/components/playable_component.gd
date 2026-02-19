class_name PlayableComponent
extends Component

enum CardColor { YELLOW, RED, GREEN, BLUE, WILD }
enum CardValue { SKIP = 10, REVERSE = 11, PLUSTWO = 12, PLUSFOUR = 13 }

@export var color: CardColor = CardColor.YELLOW
@export var value: int = 0 as CardValue
