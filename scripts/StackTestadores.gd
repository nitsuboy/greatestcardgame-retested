extends Stack

@export var tests : int = 0

func _ready() -> void:
	connect("child_exiting_tree",exiting)

func exiting(carta:Carta):
	await get_tree().process_frame
	filter.append(carta.id)

func _on_Cartaposta(carta:Carta):
	cartaposta(carta)
	filter.erase(carta.id)
	match carta.id:
		12:
			filter.append(4)
			filter.append(5)
			filter.append(8)
			tests += 2
		4:
			tests += 1
		5:
			tests += 1
		8:
			filter.append(12)
	
#on the spot
