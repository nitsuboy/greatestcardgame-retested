extends Node
class_name GameManager

signal game_started
signal turn_changed(current_player_index: int)
signal game_ended(winner: Player)

const CardType = preload("res://scripts/cards/Enums.gd").CardType
enum GameState { INIT, START_TURN, PLAYER_ACTION, RESOLVE_ACTION, END_TURN, CHECK_WIN, GAME_OVER }

@onready var dealer: Dealer = $Dealer
@onready var dice: Node = $Dice
@onready var table: Table = $Table
@onready var players: Array[Player] = [$Player]  # pode carregar dinamicamente

var current_player_index := 0
var desafio_visible_cards: Array[CardData] = []
var state: GameState = GameState.INIT

# Dados temporários para resolução da jogada
var pending_action = null

func _ready() -> void:
	change_state(GameState.INIT)

func change_state(new_state: GameState) -> void:
	state = new_state
	print(state)
	match state:
		GameState.INIT:
			start_game()
		GameState.START_TURN:
			start_turn()
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

func start_game() -> void:
	dealer.LoadDecks()
	DealInitialHands()
	setup_table_desafios()
	emit_signal("game_started")
	change_state(GameState.START_TURN)

func DealInitialHands() -> void:
	for player in players:
		dealer.DealInitialHand(player)

func setup_table_desafios(count: int = 5) -> void:
	desafio_visible_cards.clear()
	for i in range(count):
		var card : CardData = dealer.DrawCard(CardType.QUESTION)
		if card:
			desafio_visible_cards.append(card)
			table.AddDesafioCard(card)

func start_turn() -> void:
	var player = players[current_player_index]
	player.start_turn()
	
	player.connect("ActionChosen", Callable(self, "_on_player_action"), CONNECT_ONE_SHOT)
	player.connect("TurnEnded", Callable(self, "_on_turn_ended"), CONNECT_ONE_SHOT)

func _on_player_action(action_data: Dictionary) -> void:
	pass

func confirm_player_action(action) -> void:
	# Chame este método quando o jogador humano escolher a jogada
	pending_action = action
	change_state(GameState.RESOLVE_ACTION)

func resolve_action() -> void:
	if pending_action == null:
		change_state(GameState.END_TURN)
		return

	var player = players[current_player_index]
	var action = pending_action
	pending_action = null

	# Exemplo: ação de tentar um teste
	if action.type == "test":
		var roll_result = dice.roll()
		if ChallengeEvaluator.IsSuccessfulRoll(action.test_name, action.desafio_card, roll_result):
			player.add_point()
		dealer.discard_card(action.test_card)
		desafio_visible_cards.erase(action.desafio_card)
		table.remove_desafio_card(action.desafio_card)
		replace_desafio_if_available()
		var bonus = dealer.draw_card(CardType.ACTION)
		if bonus:
			player.add_card_to_hand(bonus)
		player.consume_test()

	change_state(GameState.CHECK_WIN)

func end_turn() -> void:
	current_player_index = (current_player_index + 1) % players.size()
	change_state(GameState.START_TURN)

func check_win_condition() -> void:
	for player in players:
		if player.points >= 6:
			emit_signal("game_ended", player)
			change_state(GameState.GAME_OVER)
			return
	change_state(GameState.END_TURN)

func replace_desafio_if_available() -> void:
	var new_card = dealer.draw_card(CardType.QUESTION)
	if new_card:
		desafio_visible_cards.append(new_card)
		table.add_desafio_card(new_card)
