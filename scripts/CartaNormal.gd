extends Carta
class_name CartaNormal

@export var carta_icon_id:int = 100
@export var carta_desc_str:String = "lorem ipsun"
@export var carta_tipo:String = "verde"

@onready var carta_icon:TextureRect = $front/margin/flex_container/CenterContainer/icon_rect
@onready var carta_desc:RichTextLabel = $front/margin/flex_container/centering_container/desc_label

func _ready() -> void:
	carta_nome_label.text = carta_nome 
	carta_desc.text = carta_desc_str
	carta_icon.texture = load("res://tex/icon/%d.png"%carta_icon_id)
	carta_tras_background.texture = load("res://tex/card/"+carta_tipo+"b.png")
	carta_frente_background.texture = load("res://tex/card/"+carta_tipo+"f.png")
	connect("mouse_entered",_on_mouse_entered)
	connect("mouse_exited",_on_mouse_exited)
	connect("gui_input",_on_gui_input)

func  _process(delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position()
		Globals.is_dragging = true
		rotation_degrees = 0
		if Input.is_action_just_released("mouse_left"):
			Globals.is_dragging = false
			dragging = false
			card_is_focused(false)
			check_drop()

func check_drop():
	var drop_area = get_global_mouse_position()
	var play_area = get_tree().get_nodes_in_group("dropplace")
	
	for i in play_area:
		if i.get_global_rect().has_point(drop_area):
			i.on_card_dropped(self)
			return
	Move(.1,snap_pos,snap_rot)
