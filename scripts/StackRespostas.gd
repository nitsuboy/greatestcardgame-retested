extends Stack

@export var tests : int = 0

func _ready() -> void:
	connect("child_exiting_tree",exiting)

func exiting(carta:Carta):
	await get_tree().process_frame
	filter.append(carta.id)

func _on_Cartaposta(carta:Carta):
	cartaposta(carta)
	
#on the spot
