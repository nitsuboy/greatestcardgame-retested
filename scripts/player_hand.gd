class_name PlayerHand
extends Node2D

@export var hand_curve: Curve
@export var rotation_curve: Curve

@export var max_rotation_degrees: float = .17
@export var x_sep: int = 20
@export var y_min: int = 0
@export var y_max: int = -100
@export var hand_size: int = 500

var pos_arr: Array


func get_card(index: int) -> Card:
	if index < get_child_count():
		return get_child(index)
	return null


func raise_hand() -> void:
	move(.1, Vector2i(0, 0))


func lower_hand() -> void:
	move(.1, Vector2i(0, 100))


func block_hand() -> void:
	await get_tree().process_frame
	for c in get_children():
		var draggable = EntitySystem.get_comp(c.entity, DraggableComponent)
		if draggable:
			DragSystem.lock_drag(draggable, c)
		var hover = EntitySystem.get_comp(c.entity, HoverbleComponent)
		if hover:
			HoverSystem.lock_hover(hover)


func unblock_hand() -> void:
	await get_tree().process_frame
	for c in get_children():
		var draggable = EntitySystem.get_comp(c.entity, DraggableComponent)
		if draggable:
			DragSystem.unlock_drag(draggable, c)
		var hover = EntitySystem.get_comp(c.entity, HoverbleComponent)
		if hover:
			HoverSystem.unlock_hover(hover)


func add_card(card: Card) -> void:
	add_child(card)


func remove_card(card: Card) -> void:
	remove_child(card)


func clear_hand() -> void:
	for card in get_children():
		remove_child(card)


func move_card(card: Card) -> void:
	var insert_index = card.get_index()
	if insert_index + 1 < pos_arr.size():
		if card.position.x > pos_arr[insert_index + 1].x:
			insert_index += 1
			move_child(card, insert_index)
			atualizar_cartas()
			return
	if insert_index - 1 >= 0:
		if card.position.x < pos_arr[insert_index - 1].x:
			insert_index -= 1
			move_child(card, insert_index)
			atualizar_cartas()
			return


func atualizar_cartas() -> void:
	await get_tree().process_frame
	pos_arr.clear()
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
		pos_arr.append(final)
		card.snap_pos = final
		card.snap_rot = max_rotation_degrees * rot_multiplier
		var draggable = EntitySystem.get_comp(card.entity, DraggableComponent)
		if not draggable:
			card.move(.1, final)
			card.rotate(.1, max_rotation_degrees * rot_multiplier)
			continue
		if !draggable.dragging:
			card.move(.1, final)
			card.rotate(.1, max_rotation_degrees * rot_multiplier)


func move(dur: float, target: Vector2, start: Vector2 = position) -> void:
	var t: Tween = create_tween()
	t.parallel().tween_property(self, "position", target, dur).set_trans(Tween.TRANS_CUBIC).from(
		start
	)
	await t.finished


func _on_child_exiting_tree(_node: Node) -> void:
	atualizar_cartas()


func _on_child_entered_tree(_node: Node) -> void:
	atualizar_cartas()
