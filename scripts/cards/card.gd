class_name Card
extends Control

const CARD_TYPE = preload("res://scripts/cards/Enums.gd").CardType

const SIZE := Vector2(200, 200)
# Referências internas para UI

var holder: Player
var dragging: bool = false
var snap_pos: Vector2
var snap_rot: float

var card_data: CardData

@onready var title_label = $Panel/MarginContainer/Front/Title
@onready var description_label = $Panel/MarginContainer/Front/Description
@onready var artwork = $Panel/MarginContainer/Front/Artwork
#@onready var background = $BackgroundColorRect



func _ready() -> void:
	if card_data:
		_apply_card_data()
		for c in card_data.components:
			c.ready(self)


func _process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position()
		if get_parent() is PlayerHand:
			holder.hand.move_card(self)
		Globals.is_dragging = true


func _apply_card_data() -> void:
	# Atualiza os elementos de UI
	title_label.text = card_data.card_name
	description_label.text = card_data.description
	artwork.texture = card_data.artwork
	#background.color = _get_color_for_type(card_data)


func card_is_focused(value: bool) -> void:
	if Globals.is_dragging:
		return
	if value:
		z_index = 10
		await resize(1.2)
	else:
		z_index = 0
		await resize(1.0)



# interaction


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		for c in card_data.components:
			c.on_drag_start(self)
	if event.is_action_released("mouse_left"):
		var drop = check_drop()
		for c in card_data.components:
			c.on_drag_end(self)
			if drop:
				c.on_drop(self, drop)


func _on_mouse_entered() -> void:
	card_is_focused(true)


func _on_mouse_exited() -> void:
	card_is_focused(false)


# procedural animation


<<<<<<< HEAD:scripts/cards/Card.gd
func Move(
=======
func move(
>>>>>>> proto-base:scripts/cards/card.gd
	dur: float, target: Vector2, target_rot: float = rotation_degrees, start: Vector2 = position
):
	var t: Tween = create_tween()
	t.parallel().tween_property(self, "position", target, dur).set_trans(Tween.TRANS_CUBIC).from(
		start
	)
	t.parallel().tween_property(self, "rotation_degrees", target_rot, dur).set_trans(
		Tween.TRANS_CUBIC
	)
	await t.finished


<<<<<<< HEAD:scripts/cards/Card.gd
func Rotate(dur: float, target_rot: float):
=======
func rotate(dur: float, target_rot: float):
>>>>>>> proto-base:scripts/cards/card.gd
	var t: Tween = create_tween()
	t.parallel().tween_property(self, "rotation", target_rot, dur).set_trans(Tween.TRANS_CUBIC)
	await t.finished


<<<<<<< HEAD:scripts/cards/Card.gd
func Scale(s: float) -> void:
=======
func resize(s: float) -> void:
>>>>>>> proto-base:scripts/cards/card.gd
	var t: Tween = create_tween()
	t.tween_property(self, "scale", Vector2(s, s), 0.4).set_trans(Tween.TRANS_BACK).set_ease(
		Tween.EASE_OUT
	)
	await t.finished


# Utils


<<<<<<< HEAD:scripts/cards/Card.gd
func CheckDrop() -> DropZone:
=======
func check_drop() -> DropZone:
>>>>>>> proto-base:scripts/cards/card.gd
	var drop_area = get_global_mouse_position()
	var play_area = get_tree().get_nodes_in_group("dropplace")

	for i in play_area:
		if i.shape.get_rect().has_point(i.to_local(drop_area)):
			return i
	return null


func is_node_of_class(node: Resource, class_string: String) -> bool:
	if node.get_script() and node.get_script().get_global_name() == class_string:
		return true
	return false


<<<<<<< HEAD:scripts/cards/Card.gd
func GetComponent(target_type: String):
=======
func get_component(target_type: String):
>>>>>>> proto-base:scripts/cards/card.gd
	for component in card_data.components:
		if is_node_of_class(component, target_type):
			return component
	return null
