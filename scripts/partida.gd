extends Node2D
class_name Partida

@export var num_jogadores:int = 4

# aqui ta feio mas infelizmente n tem como ser automatico, tem nas anotações.md
var jpo5 = [575,664,1168,395,897,-16,255,-16,-16,395]
var jpo4 = [575,664,1168,324,575,-16,-16,324]
var jro4 = [0,-90,180,90] # fazer em radiano mesmo depois
var jpo3 = [575,664,897,-16,255,-16]
var jpo2 = [575,664,575,-16]
# e caso n seja o jogador diminuir tamanho
var jogador_scene:PackedScene = preload("res://scenes/Jogador.tscn")
var jogadores:Dictionary = {}
var estado: int = 0

enum estado_jogo {JOGANDO,NAO_JOGANDO}

func _ready() -> void:
	var jogadores_node = $jogadores
	for i in range(num_jogadores):
		var jogador:Jogador = jogador_scene.instantiate()
		jogador.nome = "jogador %d" % (i + 1)
		jogador.set_player_id(i + 1) #Metodo de id customizavel
		# colocar swith if ou fazer uma matriz tanto faz
		jogador.position.x = jpo4[i+i]
		jogador.position.y = jpo4[i+i+1]
		jogador.rotation = deg_to_rad(jro4[i])
		# pro multiplayer
		if i == 0:
			jogador.evoce = true
		
		jogadores[i+1] = jogador
		jogadores_node.add_child(jogador)

# Redundante, usar dicionario https://docs.godotengine.org/pt-br/3.5/classes/class_dictionary.html
func get_jogador_by_id(player_id: int) -> Node2D:
	for jogador in jogadores:
		if jogador.get_player_id() == player_id:  # Assuming get_player_id() exists
			return jogador
	return null

# Example method to reset all players
func reset_all_players() -> void:
	for jogador in jogadores:
		jogador.reset()  # Assuming a `reset` method exists in the player script

# isso pode causar problema de sincronia
# Example method to determine the next player's turn
func get_next_player(current_player_id: int) -> Node2D:
	var next_id = (current_player_id % jogadores.size()) + 1
	return get_jogador_by_id(next_id)
	
func _process(delta: float) -> void:
	# state machine simples
	match estado:
		estado_jogo.JOGANDO:
			pass
		estado_jogo.NAO_JOGANDO:
			pass
		
