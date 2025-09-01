extends Control
class_name Player

signal ActionChosen(action_data)
signal TurnEnded

var id: String
var is_human: bool = true
var points: int = 0
var hand: Array[CardData] = []
var test_limit: int = 1
var tests_taken: int = 0

func _init(_name: String = "Player", _is_human: bool = true):
	id = _name
	is_human = _is_human

# --- Turno ---
func start_turn() -> void:
	tests_taken = 0
	print(id, " starting turn.")
	if is_human:
		# Em jogo real: mostrar interface, botões, etc.
		print("Waiting for human input...")
	else:
		# Em IA: já decidir ação automaticamente
		decide_action_ai()

func end_turn() -> void:
	print(name, " ending turn.")
	emit_signal("TurnEnded")

func can_attempt_test() -> bool:
	return tests_taken < test_limit

func consume_test() -> void:
	tests_taken += 1

func add_point() -> void:
	points += 1

func set_test_limit(limit: int) -> void:
	test_limit = limit

# --- Cartas ---
func add_card_to_hand(card: CardData) -> void:
	hand.append(card)

func remove_card_from_hand(card: CardData) -> void:
	hand.erase(card)

# --- Input genérico ---
func decide_action_ai() -> void:
	# IA simples de exemplo:
	await get_tree().process_frame
	if hand.size() > 0:
		var chosen = hand[0] # Sempre pega a primeira carta
		emit_signal("ActionChosen", {"type": "test", "card": chosen})
	else:
		emit_signal("ActionChosen", {"type": "pass"})

func on_human_action_chosen(action_data: Dictionary) -> void:
	# Chamada pela UI quando jogador humano escolhe algo
	emit_signal("ActionChosen", action_data)
