extends CardComponent
class_name DraggableComponent

func on_drag_start(_card: Card) -> void:
	var xf: Transform2D = _card.get_global_transform()
	var scale_x = xf.x.length() 
	var rodtation = xf.x.angle()
	_card.Scale(1.2/(scale_x/_card.scale.x))
	_card.Rotate(0.1,_card.rotation - rodtation)  
	_card.dragging = true

func on_drag_end(_card: Card) -> void:
	_card.dragging = false
	Globals.is_dragging = false
	_card.card_is_focused(false)
	_card.Move(0.1,_card.snap_pos,_card.snap_rot)
