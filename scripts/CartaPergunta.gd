extends Carta
class_name CartaPergunta

@export var carta_perg_str:String = "lorem ipsun"
@export var respostas:Array

@onready var carta_perg:RichTextLabel = $front/margin/flex_container/centering_container/desc_label
@onready var carta_res:RichTextLabel = $back/margin/centering_container/HBoxContainer/desc_label2

func _ready() -> void:
	carta_nome_label.text = "pergunta"
	carta_perg.text = carta_perg_str
	carta_res.text = ""
	for i in 6:
		for j in 6:
			if respostas[i][j]:
				carta_res.text += "%d "%(j+1)
		carta_res.text += "\n"
	print(respostas)
	connect("mouse_entered",_on_mouse_entered)
	connect("mouse_exited",_on_mouse_exited)
	connect("gui_input",_on_gui_input)

func SetPerguntas(c):
	for i in 6:
		respostas.append([false,false,false,false,false,false])
	for i in c:
		for j in i["diceroll"]:
			respostas[i["anwser"]-1][j-1] = true

	
