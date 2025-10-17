extends Container
class_name VStaticContainer


func _init() -> void:
	self.child_entered_tree.connect(Sort)
	self.child_exiting_tree.connect(Sort)
	self.child_order_changed.connect(SortChange)


func Sort(_node: Node) -> void:
	await get_tree().process_frame
	var ncards := get_child_count()
	if ncards == 0:
		return
	var offset: int = 50
	for i in ncards:
		var pos = Vector2(0, i * offset)
		var card: Card = get_child(i)
		card.snap_pos = pos
		card.snap_rot = 0
		card.Move(.1, pos, 0)


func SortChange() -> void:
	var ncards := get_child_count()
	if ncards == 0:
		return
	var offset: int = 50
	for i in ncards:
		var pos = Vector2(0, i * offset)
		var card: Card = get_child(i)
		card.snap_pos = pos
		card.snap_rot = 0
		card.Move(.1, pos, 0)
