class_name GameManager
extends Node2D

enum GameState { INIT, START_TURN, PLAYER_ACTION, RESOLVE_ACTION, END_TURN, CHECK_WIN, GAME_OVER }
const CARD_TYPE = preload("res://scripts/cards/Enums.gd").CardType

var players: Array[Player] = []  # pode carregar dinamicamente
var questions: Array[QuestionZone] = []
var current_player_index: int = 0
var state: GameState = GameState.INIT

# Dados temporários para resolução da jogada

var pending_action = null

@onready var dealer: Dealer = $Dealer


func _ready() -> void:
	for p in $players.get_children():
		players.append(p)
	for q in $questions.get_children():
		questions.append(q)
	change_state(GameState.INIT)


func change_state(new_state: GameState) -> void:
	state = new_state
	match state:
		GameState.INIT:
			start_game()
		GameState.START_TURN:
			start_turn()
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


func start_game() -> void:
	dealer.load_decks()
	deal_initial_hands()
	setup_questions()
	change_state(GameState.START_TURN)


func deal_initial_hands(count: int = 5) -> void:
	for player in players:
		for i in range(count):
			var card: Card = dealer.draw_card(CARD_TYPE.ANSWER)
			if card:
				player.add_card_to_hand(card)


func setup_questions(_count: int = 5) -> void:
	for q in questions:
		var card: Card = dealer.draw_card(CARD_TYPE.QUESTION)
		q.set_question(card)


func start_turn() -> void:
	pass


func check_win_condition() -> void:
	for player in players:
		if player.points >= 6:
			emit_signal("game_ended", player)
			change_state(GameState.GAME_OVER)
			return
	change_state(GameState.END_TURN)


# --- func ---


func roll_dice() -> int:
	var result: int = randi_range(1, 6)
	return result
