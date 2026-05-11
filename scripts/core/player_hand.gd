class_name PlayerHand
extends Node2D

enum BlockMode { NONE, DRAG_ONLY, HOVER_ONLY, ALL }

@export var hand_curve: Curve
@export var rotation_curve: Curve

@export var max_rotation_degrees: float = .17
@export var x_sep: int = 20
@export var y_min: int = 0
@export var y_max: int = -100
@export var hand_size: int = 500

var pos_arr: Array
var block_mode: BlockMode = BlockMode.ALL
var card_offsets: Dictionary[Card, Vector2] = {}  # offset visual por carta


func get_card(index: int) -> Card:
	if index < get_child_count():
		return get_child(index)
	return null


func raise_hand() -> void:
	move(.1, Vector2i(0, 0))


func lower_hand() -> void:
	move(.1, Vector2i(0, 100))


func block_card(card: Card, block_drag: bool = true, block_hover: bool = true) -> void:
#	var draggable = EntitySystem.get_comp(card.entity, DraggableComponent)
#	if draggable and block_drag:
#		#DragSystem.lock_drag(draggable, card)
#		pass
#	var hover = EntitySystem.get_comp(card.entity, HoverableComponent)
#	if hover and block_hover:
	#HoverSystem.lock_hover(hover)
	pass


func unblock_card(card: Card) -> void:
#	var draggable = EntitySystem.get_comp(card.entity, DraggableComponent)
#	if draggable:
#		#DragSystem.unlock_drag(draggable, card)
#		pass
#	var hover = EntitySystem.get_comp(card.entity, HoverableComponent)
#	if hover:
	#HoverSystem.unlock_hover(hover)
	pass


func block_hand(block_drag: bool = true, block_hover: bool = true) -> void:
	block_mode = (
		BlockMode.ALL
		if (block_drag and block_hover)
		else (
			BlockMode.DRAG_ONLY
			if block_drag
			else BlockMode.HOVER_ONLY if block_hover else BlockMode.NONE
		)
	)
	await get_tree().process_frame
	for c in get_children():
		block_card(c, block_drag, block_hover)


func unblock_hand() -> void:
	block_mode = BlockMode.NONE
	await get_tree().process_frame
	for c in get_children():
		unblock_card(c)


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
			update_cards()
			return
	if insert_index - 1 >= 0:
		if card.position.x < pos_arr[insert_index - 1].x:
			insert_index -= 1
			move_child(card, insert_index)
			update_cards()
			return


func update_cards() -> void:
	await get_tree().process_frame
	pos_arr.clear()
	if block_mode != BlockMode.NONE:
		match block_mode:
			BlockMode.ALL:
				block_hand(true, true)
			BlockMode.DRAG_ONLY:
				block_hand(true, false)
			BlockMode.HOVER_ONLY:
				block_hand(false, true)
	else:
		unblock_hand()
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
		if not card.world or card.entity_id == -1:
			card.position = final
			card.rotation = max_rotation_degrees * rot_multiplier
			continue
		if card.world.has_component(card.entity_id, DragState):
			continue
		card.move(.1, final)
		card.rotate(.1, max_rotation_degrees * rot_multiplier)


func move(dur: float, target: Vector2, start: Vector2 = position) -> void:
	var t: Tween = create_tween()
	t.parallel().tween_property(self, "position", target, dur).set_trans(Tween.TRANS_CUBIC).from(
		start
	)
	await t.finished


func _on_child_exiting_tree(_node: Node) -> void:
	update_cards()


func _on_child_entered_tree(_node: Node) -> void:
	update_cards()
