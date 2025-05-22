extends Control
class_name Carta

const SIZE := Vector2(100, 140)

@export var id:int
@export var carta_nome:String

@onready var carta_nome_label:Label = $front/margin/flex_container/name_label
@onready var carta_frente_background:TextureRect = $front
@onready var carta_tras_background:TextureRect = $back

var dragging : bool = false
var snap_pos : Vector2
var snap_rot : float

func  _ready() -> void:
	pass

func Flip(flipped:bool) -> void:
	carta_frente_background.visible = !flipped
	carta_frente_background.visible = flipped

func Move(dur:float,target:Vector2,target_rot:float=rotation_degrees,start:Vector2=position):
	var t: Tween = create_tween()
	t.parallel().tween_property(self,"position",target,dur).set_trans(Tween.TRANS_CUBIC).from(start)
	t.parallel().tween_property(self,"rotation_degrees",target_rot,dur).set_trans(Tween.TRANS_CUBIC)
	await t.finished

func HoverAnim(type:int) -> void:
	var t: Tween = create_tween()
	match type:
		0:
			t.tween_property(self,"scale",Vector2(1.5,1.5),0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		1:
			t.tween_property(self,"scale",Vector2.ONE,0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	await t.finished

func _on_gui_input(event: InputEvent) -> void:
	if dragging:
		return
	if event.is_action_pressed("mouse_left"):
		dragging = true

func _on_mouse_entered() -> void:
	card_is_focused(true)

func _on_mouse_exited() -> void:
	card_is_focused(false)

func card_is_focused(value:bool) -> void:
	if Globals.is_dragging:
		return
	if value:
		z_index = 10
		await HoverAnim(0)
	else:
		z_index = 0
		await HoverAnim(1)
