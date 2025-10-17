class_name QuestionZone
extends Control

@export var static_container: VStaticContainer
@export var question_node: Control
@export var answers: Array[int] = [0, 0, 0, 0, 0, 0]
@export var debug: RichTextLabel

var question: Array


func _process(_delta: float) -> void:
	debug.text = str(answers)


func clear_question():
	question = []
	for n in question_node.get_children():
		question_node.remove_child(n)


func set_question(card: Card) -> void:
	if not card:
		push_warning("no card")
		return
	clear_question()
	question_node.add_child(card)
	card.position = Vector2i.ZERO
	var q = card.get_component("QuestionComponent")
	if !q:
		push_warning("question dont have any answer")
		return
	question = q.valid_answers


func test():
	var idx = 0
	for a in answers:
		for i in a:
			var r = randi_range(0, 5)
			if question[idx][r]:
				pass
		idx += 1
