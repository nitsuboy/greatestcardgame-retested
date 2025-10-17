extends Node2D
class_name PlayerHand

@export var hand_curve: Curve
@export var rotation_curve: Curve

@export var max_rotation_degrees := 10
@export var x_sep := 20
@export var y_min := 0
@export var y_max := -100
@export var hand_size := 500


func AddCard(card: Card) -> void:
	add_child(card)


func RemoveCard(card: Card) -> void:
	remove_child(card)


func ClearHand() -> void:
	for card in get_children():
		remove_child(card)


func AtualizarCartas() -> void:
	await get_tree().process_frame
	var ncards: int = get_child_count()
	if ncards == 0:
		return
	var offset := hand_size / 2.0
	var c = hand_size / (2.0 * ncards)
	for i in ncards:
		var card: Card = get_child(i)
		var t := float(i) / float(max(1, ncards - 1))
		var y_multiplier := hand_curve.sample(t)
		var rot_multiplier := rotation_curve.sample(t)
		if ncards == 1:
			y_multiplier = 1.0
			rot_multiplier = 0.0
		var final: Vector2 = Vector2((c * ((i * 2) + 1)) - offset, y_min + y_max * y_multiplier)
		card.snap_pos = final
		card.snap_rot = max_rotation_degrees * rot_multiplier
		card.Move(.1, final, max_rotation_degrees * rot_multiplier)


func _on_child_exiting_tree(_node: Node) -> void:
	AtualizarCartas()


func _on_child_entered_tree(_node: Node) -> void:
	AtualizarCartas()
