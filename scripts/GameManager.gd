extends Node2D
class_name GameManager

signal game_started
signal turn_changed(current_player_index: int)
signal game_ended(winner: Player)

const CardType = preload("res://scripts/cards/Enums.gd").CardType
enum GameState { INIT, START_TURN, PLAYER_ACTION, RESOLVE_ACTION, END_TURN, CHECK_WIN, GAME_OVER }

@onready var dealer: Dealer = $Dealer
@onready var table: Table = $Table
@onready var players: Array[Player] = [$Player]  # pode carregar dinamicamente

var current_player_index := 0
var state: GameState = GameState.INIT

# Dados temporários para resolução da jogada
var pending_action = null

func _ready() -> void:
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
			resolve_action()
		GameState.END_TURN:
			end_turn()
		GameState.CHECK_WIN:
			check_win_condition()
		GameState.GAME_OVER:
			# nada, aguarda tela de fim
			pass

# --- ESTADOS DO JOGO ---

func StartGame() -> void:
	dealer.LoadDecks()
	DealInitialHands()
	SetupQuestions()
	emit_signal("game_started")
	ChangeState(GameState.START_TURN)

func DealInitialHands(count: int = 5) -> void:
	for player in players:
		for i in range(count):
			var card : Card = dealer.DrawCard(CardType.ANSWER)
			if card:
				player.add_card_to_hand(card)
			else :
				push_warning("no more cards")

func SetupQuestions(_count: int = 5) -> void:
	var card : Card = dealer.DrawCard(CardType.QUESTION)
	$Control.SetQuestion(card)

func StartTurn() -> void:
	var player = players[current_player_index]
	player.start_turn()
	player.connect("ActionChosen", Callable(self, "_on_player_action"))
	player.connect("TurnEnded", Callable(self, "_on_turn_ended"))

func confirm_player_action(action) -> void:
	# Chame este método quando o jogador humano escolher a jogada
	pending_action = action
	ChangeState(GameState.RESOLVE_ACTION)

func resolve_action() -> void:
	if pending_action == null:
		ChangeState(GameState.END_TURN)
		return

	var player = players[current_player_index]
	var action = pending_action
	pending_action = null

	# Exemplo: ação de tentar um teste
	if action.type == "test":
		var roll_result = RollDice()
		if ChallengeEvaluator.IsSuccessfulRoll(action.test_name, action.desafio_card, roll_result):
			player.add_point()
		dealer.discard_card(action.test_card)
		table.remove_desafio_card(action.desafio_card)
		var bonus = dealer.draw_card(CardType.ACTION)
		if bonus:
			player.add_card_to_hand(bonus)
		player.consume_test()

	ChangeState(GameState.CHECK_WIN)

func end_turn() -> void:
	current_player_index = (current_player_index + 1) % players.size()
	ChangeState(GameState.START_TURN)

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
