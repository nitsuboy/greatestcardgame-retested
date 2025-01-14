extends Node2D

@export var jogador_scene: PackedScene
var jogadores = []

func setup_jogadores(num_jogadores: int) -> void:
	for jogador_existente in jogadores:
		jogador_existente.queue_free()
		jogadores.clear()
		
		for i in range(num_jogadores):
			var jogador = jogador_scene.instantiate()
			jogador.name = "jogador_%d" % (i + 1)
			jogador.set_player_id(i + 1)
			jogador.position = Vector2(100 * i, 0)
			add_child(jogador)
			jogadores.append(jogador)
			
func get_jogador_by_id(player_id: int) -> Node2D:
	for jogador in jogadores:
		if jogador.get_player_id() == player_id:  # Assuming get_player_id() exists
			return jogador
	return null

# Example method to reset all players
func reset_all_players() -> void:
	for jogador in jogadores:
		jogador.reset()  # Assuming a `reset` method exists in the player script

# Example method to determine the next player's turn
func get_next_player(current_player_id: int) -> Node2D:
	var next_id = (current_player_id % jogadores.size()) + 1
	return get_jogador_by_id(next_id)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
