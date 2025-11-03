class_name Card
extends Control

var entity: Entity

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

func _ready():
	entity = Entity.new()
	var nc: NodeComponent = NodeComponent.new()
	nc.node = self
	entity.components.append(nc)
	for c in card_data.components:
		entity.components.append(c.duplicate())
	print(EntitySystem.has_comp(entity,DraggableComponent))

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
		await resize(1.2)
	else:
		z_index = 0
		await resize(1.0)

func _on_gui_input(event: InputEvent) -> void:
	print(self)
	
	if not entity:
		return
		
	var e_args = CardInputEventArgs.new(event, entity)
	var e = CardInputEvent.new(e_args)
	e.start()

func _on_control_mouse_exited() -> void:
	if not entity:
		return
		
	var e_args = CardInputEventArgs.new(null, entity)
	var e = CardInputEvent.new(e_args)
	e.start()

# procedural animation


func move(
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
