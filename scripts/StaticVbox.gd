extends Container
class_name VStaticContainer

@export var offset: Vector2 = Vector2.ZERO


func _init() -> void:
	self.child_entered_tree.connect(Sort)
	self.child_exiting_tree.connect(Sort)
	self.child_order_changed.connect(SortChange)


func Sort(_node: Node) -> void:
	await get_tree().process_frame
	var ncards := get_child_count()
	if ncards == 0:
		return
	for i in ncards:
		var pos = i * offset
		var card: Card = get_child(i)
		card.snap_pos = pos
		card.snap_rot = 0
		card.Move(.1, pos, 0)


func SortChange() -> void:
	var ncards := get_child_count()
	if ncards == 0:
		return
	for i in ncards:
		var pos = i * offset
		var card: Card = get_child(i)
		card.snap_pos = pos
		card.snap_rot = 0
		card.Move(.1, pos, 0)
