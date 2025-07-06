extends Button

const CARD = preload("res://scenes/card_question.tscn")
var pers = []
var f = false

func _on_pressed() -> void:
	var c = $"../../Crupie".GetCardFromTop(0)
	if c != null:
		$"../../Mao".PuxarCarta(c["id"],c["icon_id"],c["cor"],c["desc"],c["nome"])

func _on_button_4_pressed() -> void:
	$"../../Crupie".Shuffle(0)
	$"../../Crupie".Shuffle(1)
	$"../../Crupie".Shuffle(2)


func _on_button_2_pressed() -> void:
	var c = $"../../Crupie".GetCardFromTop(2)
	if c != null:
		var new_card = CARD.instantiate()
		new_card.carta_perg_str = c["questionText"]
		new_card.SetPerguntas(c["anwser"])
		pers.append(new_card)
		$"../../Control/VBoxContainer".add_child(new_card)


func _on_button_3_pressed() -> void:
	var cq:CartaPergunta
	for i in $"../../Control/VBoxContainer".get_children():
		if i is CartaPergunta:
			cq = i
		if i is CartaNormal:
			if cq.respostas[i.id-13].has(true):
				var c = $"../../Crupie".GetCardFromTop(1)
				if c != null:
					$"../../Mao".PuxarCarta(c["id"],c["icon_id"],c["cor"],c["desc"],c["nome"])
	for i in $"../../Control/VBoxContainer".get_children():
		await i.Move(.1,Vector2(2000,0))
		$"../../Control/VBoxContainer".remove_child(i)
		if i is CartaPergunta:
			$"../../Crupie".ParaDescarte(i.id,2)
		if i is CartaNormal:
			$"../../Crupie".ParaDescarte(i.id,0)
		
func _on_button_5_pressed() -> void:
	f = !f
	for i in pers:
		i.Flip(f)
