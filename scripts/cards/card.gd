class_name Card
extends Control

const CARD_TYPE = preload("res://scripts/cards/Enums.gd").CardType

const SIZE := Vector2(200, 200)
# Referências internas para UI

var entity: Entity
var holder: Player
var dragging: bool = false
var snap_pos: Vector2
var snap_rot: float
var card_data: CardData
var card_type: CARD_TYPE
var flipped: bool = false

@onready var title_label = $Panel/MarginContainer/Front/Title
@onready var description_label = $Panel/MarginContainer/Front/Description
@onready var artwork = $Panel/MarginContainer/Front/Artwork
@onready var back = $Panel/Back
#@onready var background = $BackgroundColorRect


func _init() -> void:
	entity = Entity.new()
	var nc: NodeComponent = NodeComponent.new()
	nc.node = self
	entity.components.append(nc)


func _ready() -> void:
	_apply_card_data()

	back.visible = flipped

	for c: Component in card_data.components:
		entity.components.append(c.duplicate())
		if "cursor" in c:
			get_child(1).mouse_default_cursor_shape = c.cursor_shape


func _apply_card_data() -> void:
	# Atualiza os elementos de UI
	title_label.text = card_data.card_name
	description_label.text = card_data.description
	artwork.texture = card_data.artwork
	#background.color = _get_color_for_type(card_data)


# interaction
func card_is_focused(value: bool) -> void:
	if Globals.is_dragging:
		return
	if value:
		z_index = 10
	else:
		z_index = 0


func _on_gui_input(event: InputEvent) -> void:
	if not entity:
		return

	# TODO: move this to input system. please don't let it be here
	var e_args = CardInputEventArgs.new(event, entity)
	var e = CardInputEvent.new(e_args)
	e.start()


func _on_mouse_exited() -> void:
	if not entity:
		return

	# TODO: move this to input system. please don't let it be here
	var e_args = CardInputEventArgs.new(null, entity)
	var e = CardInputEvent.new(e_args)
	e.start()


# procedural animation


func flip(state):
	back.visible = state


func move(dur: float, target: Vector2, start: Vector2 = position):
	var t: Tween = create_tween()
	t.parallel().tween_property(self, "position", target, dur).set_trans(Tween.TRANS_CUBIC).from(
		start
	)
	await t.finished


func rotate(dur: float, target_rot: float):
	var t: Tween = create_tween()
	t.parallel().tween_property(self, "rotation", target_rot, dur).set_trans(Tween.TRANS_CUBIC)
	await t.finished


func resize(s: float) -> void:
	var t: Tween = create_tween()
	t.tween_property(self, "scale", Vector2(s, s), 0.4).set_trans(Tween.TRANS_BACK).set_ease(
		Tween.EASE_OUT
	)
	await t.finished


func shake_negation() -> void:
	# força e duração base
	var intensity := 10.0
	var dur := 0.05

	# posição inicial (pra voltar no final)
	var original_pos := snap_pos

	# sequência de movimentos laterais
	await move(dur, original_pos + Vector2(-intensity, 0))
	await move(dur, original_pos + Vector2(intensity, 0))
	await move(dur, original_pos + Vector2(-intensity * 0.8, 0))
	await move(dur, original_pos + Vector2(intensity * 0.8, 0))
	await move(dur, original_pos)

	# pequena rotação pra dar ênfase
	await rotate(dur, deg_to_rad(-5))
	await rotate(dur, deg_to_rad(5))
	await rotate(dur, 0)


func shake_affirmation() -> void:
	# intensidade e duração base
	var intensity := 8.0
	var dur := 0.05

	# guardar posição e rotação originais
	var original_pos := snap_pos

	# movimento vertical — "sim" com a cabeça
	await move(dur, original_pos + Vector2(0, -intensity))
	await move(dur, original_pos + Vector2(0, intensity))
	await move(dur, original_pos + Vector2(0, -intensity * 0.6))
	await move(dur, original_pos + Vector2(0, intensity * 0.6))
	await move(dur, original_pos)

	# pequena rotação positiva (como um aceno de aprovação)
	await rotate(dur, deg_to_rad(5))
	await rotate(dur, 0)
