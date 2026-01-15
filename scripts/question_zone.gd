class_name QuestionZone
extends Control

const CARD_TYPE = preload("res://scripts/cards/Enums.gd").CardType

@export var static_container: VStaticContainer
@export var question_node: Control
@export var debug: RichTextLabel

var question: Array


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
	var comp = EntitySystem.get_comp(card.entity, QuestionComponent)
	if !comp:
		push_warning("question dont have any answer")
		return
	question = comp.valid_answers


func test():
	print("test start")
	var answers = static_container.get_children()
	answers.reverse()
	for c in answers:
		var comp: AnswerComponent = EntitySystem.get_comp(c.entity, AnswerComponent)
		var r = randi_range(0, 5)
		if question[comp.answer][r]:
			print("ccol")
			await c.shake_affirmation()
		else:
			await c.shake_negation()
		%Dealer.discard_card(c)
	if question_node.get_child_count() > 0:
		%Dealer.discard_card(question_node.get_child(0))
		var card: Card = %Dealer.draw_card(CARD_TYPE.QUESTION)
		set_question(card)
