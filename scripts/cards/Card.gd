extends Control
class_name Card

const CardType = preload("res://scripts/cards/Enums.gd").CardType

@export var card_data: CardData : set = set_card_data

# Referências internas para UI
@onready var title_label = $Panel/Front/Title
@onready var description_label = $Panel/Front/Description
@onready var artwork = $Panel/Front/Artwork
#@onready var background = $BackgroundColorRect

func set_card_data(value: CardData) -> void:
	card_data = value
	if is_inside_tree():
		_apply_card_data()

func _ready() -> void:
	if card_data:
		_apply_card_data()

func _apply_card_data() -> void:
	# Atualiza os elementos de UI
	title_label.text = card_data.card_name
	description_label.text = card_data.description
	artwork.texture = card_data.artwork
	#background.color = _get_color_for_type(card_data)

func _get_color_for_type(data: CardData) -> Color:
	match data.card_type:
		CardType.QUESTION:
			return Color(1, 0.3, 0.3) # vermelho
		CardType.ACTION:
			return Color(0.3, 0.3, 1) # azul
		CardType.ANSWER:
			return Color(0.3, 1, 0.3) # verde
		_:
			return Color(1, 1, 1)
