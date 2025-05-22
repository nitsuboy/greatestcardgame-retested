extends Control
class_name DropZone

signal cartaposta(carta)

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP

func on_card_dropped(card):
	print("Carta solta na DropZone:", card.name)
	cartaposta.emit(card)
