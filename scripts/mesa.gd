extends Control

var espacos:Array[Control] = []
@onready var testadores = $Testadores/colunatestadores
var carta = preload("res://scenes/card_normal.tscn")
var carta_pergunta = preload("res://scenes/card_question.tscn")

func _ready() -> void:
	for i in $problemas/linhas/linhacima.get_children():
		espacos.append(i.get_child(0))
	for i in $problemas/linhas/linhabaixo.get_children():
		espacos.append(i.get_child(0))
	adicionarpergunta()

func adicionarpergunta():
	for i in espacos:
		if i.get_child_count() != 0:
			continue
		var node:Control = Control.new()
		node.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		node.custom_minimum_size = Vector2i(100,142)
		var c :CartaPergunta= carta_pergunta.instantiate()
		i.add_child(node)
		c.scale = Vector2i.ONE * .206
		c.position = Vector2i(50,142)
		node.add_child(c)

func adicionartestador():
	var node:Control = Control.new()
	node.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	node.custom_minimum_size = Vector2i(100,142)
	var c :CartaNormal= carta.instantiate()
	testadores.add_child(node)
	c.scale = Vector2i.ONE * .206
	c.carta_tipo = "verde"
	c.position = Vector2i(50,142)
	c.carta_icon_id = "206"
	node.add_child(c)
	
	
func adicionarteste(i:int):
	var node:Control = Control.new()
	node.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	node.custom_minimum_size = Vector2i(100,142)
	var c :CartaNormal= carta.instantiate()
	espacos[i].add_child(node)
	c.scale = Vector2i.ONE * .206
	c.carta_tipo = "verde"
	c.position = Vector2i(50,142)
	node.add_child(c)

func limparteste(i:int):
	if espacos[i].get_child_count() > 1:
		espacos[i].remove_child(espacos[i].get_child(1))

func limpartestador():
	for i in testadores.get_children():
		testadores.remove_child(i)


func _on_button_2_pressed() -> void:
	limpartestador()


func _on_button_pressed() -> void:
	adicionartestador()


func _on_button_3_pressed() -> void:
	adicionarteste(randi_range(0,4))


func _on_button_4_pressed() -> void:
	limparteste(randi_range(0,4))
