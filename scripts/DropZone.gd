extends CollisionShape2D
class_name DropZone

@export var who_to_apply: Node
var global_rect: Rect2

func _ready():
	global_rect = shape.get_rect()

func on_card_dropped(card: Card):
	print("droped")
	if !card.card_data:
		push_warning("Card has no card_data")
		card.Move(0.1,card.snap_pos,card.snap_rot)
		return
	if card.card_data.effects.size() < 1:
		push_warning("Card has no effects")
		card.Move(0.1,card.snap_pos,card.snap_rot)
		return
	for effect in card.card_data.effects:
		effect.ApplyEffect(card,who_to_apply)
