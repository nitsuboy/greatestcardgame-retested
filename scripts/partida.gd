extends Node2D

@export var num_jogadores:int = 4
@export var jogador_scene:PackedScene
 
var jogadores = []

func _ready() -> void:
	var jogadores_node = $jogadores
	for i in range(num_jogadores):
		var jogador = jogador_scene.instance()
		jogador.name = "jogador %d" % (i + 1)
		jogador.set_player_id(i + 1) #Metodo de id customizavel
		jogadores_node.add_child(jogador)
		jogadores.append.jogador


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
