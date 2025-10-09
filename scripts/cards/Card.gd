extends Control
class_name Card

const CardType = preload("res://scripts/cards/Enums.gd").CardType

const SIZE := Vector2(200, 200)
# Referências internas para UI
@onready var title_label = $Panel/Front/Title
@onready var description_label = $Panel/Front/Description
@onready var artwork = $Panel/Front/Artwork

var onwer
var dragging : bool = false
var snap_pos : Vector2
var snap_rot : float

#@onready var background = $BackgroundColorRect

var card_data: CardData

func _ready() -> void:
	if card_data:
		_apply_card_data()
		for c in card_data.components:
			c.ready(self)

func _process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position()
		if onwer is Player:
			onwer.hand.MoveCard(self)
		Globals.is_dragging = true

func _apply_card_data() -> void:
	# Atualiza os elementos de UI
	title_label.text = card_data.card_name
	description_label.text = card_data.description
	artwork.texture = card_data.artwork
	#background.color = _get_color_for_type(card_data)

func card_is_focused(value:bool) -> void:
	if Globals.is_dragging:
		return
	if value:
		z_index = 10
		await Scale(1.2)
	else:
		z_index = 0
		await Scale(1.0)

# interaction

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		for c in card_data.components:
			c.on_drag_start(self)
	if event.is_action_released("mouse_left"):
		var drop = CheckDrop()
		for c in card_data.components:
			c.on_drag_end(self)
			if drop:
				c.on_drop(self, drop)

func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_HELP)
	card_is_focused(true)

func _on_mouse_exited() -> void:
	card_is_focused(false)

# procedural animation

func Move(dur:float,target:Vector2,target_rot:float=rotation_degrees,start:Vector2=position):
	var t: Tween = create_tween()
	t.parallel().tween_property(self,"position",target,dur).set_trans(Tween.TRANS_CUBIC).from(start)
	t.parallel().tween_property(self,"rotation_degrees",target_rot,dur).set_trans(Tween.TRANS_CUBIC)
	await t.finished

func Rotate(dur:float,target_rot:float):
	var t: Tween = create_tween()
	t.parallel().tween_property(self,"rotation",target_rot,dur).set_trans(Tween.TRANS_CUBIC)
	await t.finished

func Scale(s:float) -> void:
	var t: Tween = create_tween()
	t.tween_property(self,"scale",Vector2(s,s),0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await t.finished

# Utils

func CheckDrop() -> DropZone:
	var drop_area = get_global_mouse_position()
	var play_area = get_tree().get_nodes_in_group("dropplace")
	
	for i in play_area:
		if i.shape.get_rect().has_point(i.to_local(drop_area)):
			return i
	return null

func GetComponent(target_type: String):
	for component in card_data.components:
		if component.is_class(target_type):
			return component
	return null
