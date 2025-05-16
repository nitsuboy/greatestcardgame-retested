extends Node
class_name GameManager

signal GameStarted
signal TurnChanged(current_player_index: int)
signal GameEnded(winner: Player)

@onready var dealer: Dealer = $Dealer
@onready var dice: Node = $Dice
@onready var table: Node = $Table
@onready var players: Array[Player] = [$Player] # Later populate dynamically on multiplayer

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
			table.AddDesafioCard(card) # Implement on the table scene

func _StartTurn() -> void:
	var player := players[current_player_index]
	player.StartTurn() # Add turn UI logic or input enablement later
	emit_signal("TurnChanged", current_player_index)

func EndTurn() -> void:
	current_player_index = (current_player_index + 1) % players.size()
	_StartTurn()

func CheckWinCondition() -> void:
	for player in players:
		if player.points >= 6:
			emit_signal("GameEnded", player)
			return
