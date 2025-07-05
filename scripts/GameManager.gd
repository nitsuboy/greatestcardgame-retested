extends Node
class_name GameManager

signal GameStarted
signal TurnChanged(current_player_index: int)
signal GameEnded(winner: Player)

@onready var dealer: Dealer = $Dealer
@onready var dice: Node = $Dice
@onready var table: Node = $Table
@onready var players: Array[Player] = [$Player]

var current_player_index: int = 0
var desafio_visible_cards: Array[CardData] = []

func _ready() -> void:
	StartGame()

func StartGame() -> void:
	dealer._LoadDecks()
	_DealInitialHands()
	_SetupTableDesafios()
	emit_signal("GameStarted")
	_StartTurn()

func _DealInitialHands() -> void:
	for player in players:
		dealer.DealInitialHand(player)

func _SetupTableDesafios(count: int = 5) -> void:
	desafio_visible_cards.clear()
	for i in range(count):
		var card := dealer.DrawDesafioCard()
		if card:
			desafio_visible_cards.append(card)
			table.AddDesafioCard(card)

func AttemptTest(test_name: String, test_card: CardData, desafio_card: CardData) -> bool:
	var player := players[current_player_index]
	
	if not player.CanAttemptTest():
		return false
	
	if ChallengeEvaluator.IsValidTest(test_name, desafio_card):
		return false
	
	var roll_result: int = dice.Roll()
	
	if ChallengeEvaluator.IsSuccessfulRoll(test_name, desafio_card, roll_result):
		player.AddPoint()
	
	dealer.DiscardCard(test_card)
	desafio_visible_cards.erase(desafio_card)
	table.RemoveDesafioCard(desafio_card)
	_ReplaceDesafioIfAvailable()
	
	var bonus_card := dealer.DrawBonusCard()
	if bonus_card:
		player.AddCardToHand(bonus_card)
	
	player.ConsumeTest()
	CheckWinCondition()
	return true


func _ReplaceDesafioIfAvailable() -> void:
	var new_card := dealer.DrawDesafioCard()
	if new_card:
		desafio_visible_cards.append(new_card)
		table.AddDesafioCard(new_card)

func _StartTurn() -> void:
	var player := players[current_player_index]
	
	#Draw tests from the deck
	var test_limit: int = 1
	if player.HasTestador():
		test_limit = 2
		if player.HasEstágiario:
			test_limit += 1
	player.SetTestLimit(test_limit)
	
	player.StartTurn()
	emit_signal("TurnChanged", current_player_index)

func EndTurn() -> void:
	current_player_index = (current_player_index + 1) % players.size()
	_StartTurn()

func CheckWinCondition() -> void:
	for player in players:
		if player.points >= 6:
			emit_signal("GameEnded", player)
			return
