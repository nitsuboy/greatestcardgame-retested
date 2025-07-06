extends Node
class_name Crupie

signal AllDone

var decks:Dictionary
var ponteiros:Dictionary
var cartas:Dictionary
var quests:Dictionary

enum DECK {VERDE,AZUL,VERMELHO,VERDE_DESCARTE,AZUL_DESCARTE,VERMELHO_DESCARTE}

# funcionamento
#       [0,1,2,3,4]
# usadas<^       ^ >descarte

func _ready() -> void:
	decks = {
		DECK.VERDE    : [],
		DECK.AZUL     : [],
		DECK.VERMELHO : [],
	}
	
	var data_file : FileAccess = FileAccess.open("res://data/deck.json",FileAccess.READ)
	var deckdata = JSON.parse_string(data_file.get_as_text())
	for i in deckdata:
		cartas[int(i["id"])] = i
		if i["cor"] == "azul":
			for x in i["quant"]:
				decks[DECK.AZUL].append(int(i["id"]))
		else:
			for x in i["quant"]:
				decks[DECK.VERDE].append(int(i["id"]))
	data_file.close()
	
	data_file = FileAccess.open("res://data/questions.json",FileAccess.READ)
	var questdata = JSON.parse_string(data_file.get_as_text())
	for i in questdata:
		quests[int(i["id"])] = i
		decks[DECK.VERMELHO].append(int(i["id"]))
	data_file.close()
	
	ponteiros = {
		DECK.VERDE    : 0,
		DECK.AZUL     : 0,
		DECK.VERMELHO : 0,
		DECK.VERDE_DESCARTE    : decks[DECK.VERDE].size()-1,
		DECK.AZUL_DESCARTE     : decks[DECK.AZUL].size()-1,
		DECK.VERMELHO_DESCARTE : decks[DECK.VERMELHO].size()-1
	}
	
	Teste()
	emit_signal("AllDone")

func Shuffle(deck:int) -> void:
	var rng = RandomNumberGenerator.new()
	for i in range(ponteiros[deck],ponteiros[deck+3]):
		var j = decks[deck][i]
		var rd = rng.randi_range(i,ponteiros[deck+3])
		decks[deck][i] = decks[deck][rd]
		decks[deck][rd] = j

func ParaDescarte(id:int,deck:int) -> void:
	var j:int = -1
	
	if ponteiros[deck] == 0:
		return
	
	for i in ponteiros[deck]:
		if decks[deck][i] == id:
			j = i
			break
	
	if j == -1:
		return
		
	for i in range(j,decks[deck].size()-1):
		decks[deck][i] = decks[deck][i+1]
	
	decks[deck][decks[deck].size()-1] = id
	ponteiros[deck] -= 1
	ponteiros[deck+3] -= 1

func VoltarDescarte(deck:int) -> void:
	ponteiros[deck+3] = decks[deck].size()-1

func GetCardFromTop(deck:int):
	if ponteiros[deck] < ponteiros[deck+3]:
		if deck == 2:
			ponteiros[deck] += 1
			return quests[decks[deck][ponteiros[deck]-1]]
		else :
			ponteiros[deck] += 1
			return cartas[decks[deck][ponteiros[deck]-1]]
	return null

# função para vizualizaçã

func Teste() -> void:
	print(decks[DECK.AZUL])
	Shuffle(DECK.VERDE)
	Shuffle(DECK.AZUL)
	print("shuffle")
	print(decks[DECK.AZUL])
	var format_string = " %*s"
	print(format_string % [ponteiros[DECK.AZUL]*3,"^"])
	print(format_string % [ponteiros[DECK.AZUL_DESCARTE]*3,"^"])
	ParaDescarte(decks[DECK.AZUL][0],DECK.AZUL)
	print("discarte")
	print(decks[DECK.AZUL])
	print(format_string % [ponteiros[DECK.AZUL]*3,"^"])
	print(format_string % [ponteiros[DECK.AZUL_DESCARTE]*3,"^"])
