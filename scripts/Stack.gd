extends VBoxContainer
class_name Stack

@export var filter: Array[int] = []
@export var use_filter: bool = true

func _ready() -> void:
#	connect("child_exiting_tree",exiting)
	pass

func cartaposta(carta: Carta) -> void:
	if carta.get_parent() == self or not ((carta.id in filter) or not use_filter):
		carta.Move(.1,carta.snap_pos,carta.snap_rot)
		return
	carta.get_parent().remove_child(carta)
	add_child(carta)
	filter.erase(carta.id)
	await get_tree().process_frame
	carta.snap_rot = carta.rotation_degrees
	carta.snap_pos = carta.position

#func exiting(carta:Carta):
#	await get_tree().process_frame
#	filter.append(carta.id)
	
