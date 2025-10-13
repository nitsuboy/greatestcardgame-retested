extends Node2D
class_name GameManager

const CardType = preload("res://scripts/cards/Enums.gd").CardType
enum GameState { INIT, START_TURN, PLAYER_ACTION, RESOLVE_ACTION, END_TURN, CHECK_WIN, GAME_OVER }

@onready var dealer: Dealer = $Dealer

var players: Array[Player] = []  # pode carregar dinamicamente
var questions: Array[QuestionZone] = []
var current_player_index := 0
var state: GameState = GameState.INIT

# Dados temporários para resolução da jogada

var pending_action = null

func _ready() -> void:
	for p in $players.get_children():
		players.append(p)
	for q in $questions.get_children():
		questions.append(q)
	ChangeState(GameState.INIT)

func ChangeState(new_state: GameState) -> void:
	state = new_state
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
			var card : Card = dealer.DrawCard(CardType.ANSWER)
			if card:
				player.add_card_to_hand(card)

func SetupQuestions(_count: int = 5) -> void:
	for q in questions:
		var card : Card = dealer.DrawCard(CardType.QUESTION)
		q.SetQuestion(card)

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
	var result : int = randi_range(1,6)
	return result
