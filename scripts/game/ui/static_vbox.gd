class_name VStaticContainer
extends Container

@export var offset: Vector2 = Vector2.ZERO


func _init() -> void:
	self.child_entered_tree.connect(sort)
	self.child_exiting_tree.connect(sort)
	#self.child_order_changed.connect(sort_change)


func sort(_node: Node) -> void:
	await get_tree().process_frame
	var ncards := get_child_count()
	if ncards == 0:
		return
	for i in ncards:
		var pos = i * offset
		var card: Card = get_child(i)
		card.snap_pos = pos
		card.snap_rot = 0
		card.move(.5, pos)
		card.rotate(.1, 0)


func sort_change() -> void:
	var ncards := get_child_count()
	if ncards == 0:
		return
	for i in ncards:
		var pos = i * offset
		var card: Card = get_child(i)
		card.snap_pos = pos
		card.snap_rot = 0
		card.move(.1, pos)
		card.rotate(.1, 0)
