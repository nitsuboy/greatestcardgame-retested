extends Node2D

@export var card: CardData = null

func _ready():
	if card != null:
		UpdateCard()

func UpdateCard() -> void:
	$DescriptionLabel.text = card.description
	
	if card is DesafioCardData:
		UpdateDesafioCard(card)
	elif card is BonusCardData:
		UpdateBonusCard(card)
	elif card is JogoCardData:
		UpdateJogoCard(card)

func UpdateDesafioCard(desafio: DesafioCardData) -> void:
	var test_names := desafio.test_requirements.keys()
	$TestLabel.text = "Testes: " + ", ".join(test_names)

func UpdateBonusCard(bonus: BonusCardData) -> void:
	$PowerLabel.text = bonus.power_name  # example
