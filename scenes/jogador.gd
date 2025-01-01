extends Node2D

class_name Jogador

#referencia ao scrip de mão e pontos
@onready var hand = $Mao
@onready var points_label = $PointsLabel

# Total de pontos de um jogador
var pontos_totais: int = 0

#Adiciona cartas a mão do player
func adicionar_cardas(card_data: Dictionary):
	hand.num_cartas +=1 #Atualiza o número de cartas
	hand.carta = card_data["scene"] #Prepara a cena de carta
	hand.points_nodes.append(Vector2.ZERO) #Adiciona um placeholder para a carta
	hand._ready() #Atualiza o display
	update_points(card_data["points"])
		
#Atualizar os pontos do jogador
func update_points(points: int):
		pontos_totais += points
		points_label.text = "Points: " + str(pontos_totais)
		
#Remove uma carta da mão do jogador
func remover_carta(index: int):
		if index < hand.num_cartas:
				hand.num_cartad -= 1
				hand.points_node.pop_back() # remove o ultimo nó de carta
				hand._ready
				
#Mostrar o total de cartas e pontos
func mostrar_status():
		print("cartas na mão:", hand.num_cartas)
		print("pontos Totais", pontos_totais)
