class_name Card
extends Control

enum CardColor { YELLOW, RED, GREEN, BLUE, WILD }
enum CardValue {
	ZERO = 0,
	ONE = 1,
	TWO = 2,
	THREE = 3,
	FOUR = 4,
	FIVE = 5,
	SIX = 6,
	SEVEN = 7,
	EIGHT = 8,
	NINE = 9,
	SKIP = 10,
	REVERSE = 11,
	PLUSTWO = 12,
	PLUSFOUR = 13
}

const SIZE := Vector2(200, 200)
# Referências internas para UI

var holder: Player
var snap_pos: Vector2
var snap_rot: float
@export var card_data: CardData

@onready var title_label: Label = $Panel/MarginContainer/Front/Title
@onready var aux_label: Label = $Panel/MarginContainer/Front/Label
@onready var color_type: ColorRect = $Panel/MarginContainer/Front/ColorRect
@onready var back = $Panel/Back

var entity_id: int = -1
var _world: World  # injetado pelo Dealer ou WorldRunner


func post_instantiate(world: World, id := -1) -> void:
	_world = world
	entity_id = id if id != -1 else world.create_entity()
	world.add_component(entity_id, CardNodeRef.new(self))
	for c: Resource in card_data.components:
		var comp = c.duplicate(true)
		world.add_component(entity_id, comp)


func _on_gui_input(event: InputEvent) -> void:
	if entity_id == -1:
		return
	_world.events.on_card_input.emit(entity_id, event)


func _on_mouse_exited() -> void:
	if entity_id == -1:
		return
	_world.events.on_card_mouse_exited.emit(entity_id)


func _ready() -> void:
	_apply_card_data()


## Update card looks
func _apply_card_data() -> void:
	title_label.text = card_data.card_name
	aux_label.text = card_data.card_name
	match card_data.card_color:
		CardColor.YELLOW:
			color_type.color = Color.YELLOW
		CardColor.RED:
			color_type.color = Color.FIREBRICK
		CardColor.GREEN:
			color_type.color = Color.SEA_GREEN
		CardColor.BLUE:
			color_type.color = Color.NAVY_BLUE
		CardColor.WILD:
			var shader = load("res://assets/card.gdshader")
			var shader_mat = ShaderMaterial.new()
			shader_mat.shader = shader
			color_type.material = shader_mat


# interaction
func card_is_focused(value: bool) -> void:
	if Globals.is_dragging:
		return
	if value:
		z_index = 10
	else:
		z_index = 0


# procedural animation


func flip(state: bool) -> void:
	back.visible = state


func move(dur: float, target: Vector2, start: Vector2 = position) -> void:
	var t: Tween = create_tween()
	t.parallel().tween_property(self, "position", target, dur).set_trans(Tween.TRANS_CUBIC).from(
		start
	)
	await t.finished


func rotate(dur: float, target_rot: float) -> void:
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
