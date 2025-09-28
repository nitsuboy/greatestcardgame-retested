extends Control
class_name QuestionZone

@export var static_container:VStaticContainer
@export var question_node:Control
@export var answers:Array[int] = [0,0,0,0,0,0]
@export var debug:RichTextLabel

var question:QuestionCardData

func _process(delta: float) -> void:
	debug.text = str(answers)

func ClearQuestion():
	question = null
	for n in question_node.get_children():
		question_node.remove_child(n)

func SetQuestion(card: Card):
	ClearQuestion()
	question_node.add_child(card)
	card.position = Vector2i.ZERO
	question = card.card_data

func Test():
	var idx = 0
	for a in answers:
		print("testes para %d!" % idx)
		for i in a:
			var r = randi_range(0,5)
			if question.valid_answers[idx][r]:
				print("point")
		print("===========")
		idx+=1
		
