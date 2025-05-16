extends Node2D

@export var card: CardData = null

func _ready():
	if card != null:
		UpdateCard()

func UpdateCard() -> void:
	$Name_Label.text = card.name
	$DescriptionLabel.text = card.description
