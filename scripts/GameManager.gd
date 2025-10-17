extends Node2D
class_name GameManager

const CardType = preload("res://scripts/cards/Enums.gd").CardType
enum GameState { INIT, START_TURN, PLAYER_ACTION, RESOLVE_ACTION, END_TURN, CHECK_WIN, GAME_OVER }

@onready var dealer: Dealer = $Dealer
@onready var players: Array[Player] = [$Player, $Player2]  # pode carregar dinamicamente

var current_player_index := 0
var state: GameState = GameState.INIT

# Dados temporários para resolução da jogada
var pending_action = null


func _ready() -> void:
	Globals.dg = $dg
	ChangeState(GameState.INIT)


func _process(_delta: float) -> void:
	$RichTextLabel.text = "points = " + str(players[0].points)


func ChangeState(new_state: GameState) -> void:
	state = new_state
	print(state)
	match state:
		GameState.INIT:
			StartGame()
		GameState.START_TURN:
			StartTurn()
		GameState.PLAYER_ACTION:
			pass
		GameState.RESOLVE_ACTION:
			pass
		GameState.END_TURN:
			pass
		GameState.CHECK_WIN:
			pass
		GameState.GAME_OVER:
			pass


# --- ESTADOS DO JOGO ---


func StartGame() -> void:
	dealer.LoadDecks()
	DealInitialHands()
	SetupQuestions()
	ChangeState(GameState.START_TURN)


func DealInitialHands(count: int = 5) -> void:
	for player in players:
		for i in range(count):
			var card: Card = dealer.DrawCard(CardType.ANSWER)
			if card:
				player.add_card_to_hand(card)
			else:
				push_warning("no more cards")


func SetupQuestions(_count: int = 5) -> void:
	var card: Card = dealer.DrawCard(CardType.QUESTION)
	$Control.SetQuestion(card)


func StartTurn() -> void:
	pass


func check_win_condition() -> void:
	for player in players:
		if player.points >= 6:
			emit_signal("game_ended", player)
			ChangeState(GameState.GAME_OVER)
			return
	ChangeState(GameState.END_TURN)


# --- func ---


func RollDice() -> int:
	var result: int = randi_range(1, 6)
	return result
