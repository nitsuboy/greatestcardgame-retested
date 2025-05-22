extends Node2D
class_name Mao

const CARD = preload("res://scenes/card_normal.tscn")

@export var hand_curve: Curve
@export var rotation_curve: Curve

@export var max_rotation_degrees := 10
@export var x_sep := 20
@export var y_min := 50
@export var y_max := -50
@export var hand_size := 500

@onready var cartasnode = $Node2D


func PuxarCarta(icon,tipo,desc,nome) -> void:
	var new_card = CARD.instantiate()
	new_card.carta_desc_str = desc
	new_card.carta_icon_id= int(icon)
	new_card.carta_tipo = tipo
	new_card.carta_nome = nome
	new_card.position = Vector2(0,100)
	cartasnode.add_child(new_card)
	AtualizarCartas()

func DescartarCarta(crupie:Crupie,carta:Carta) -> void:
	if get_child_count() < 1:
		return
	var child := get_child(-1)
	child.reparent(get_tree().root)
	child.queue_free()
	AtualizarCartas()

func AtualizarCartas() -> void:
	await get_tree().process_frame
	var cards := cartasnode.get_child_count()
	if cards == 0:
		return
		
	var all_cards_size := Carta.SIZE.x * (cards-1) + x_sep * (cards - 1)
	var final_x_sep = x_sep
	if all_cards_size > hand_size:
		final_x_sep = (hand_size / (cards - 1)) - Carta.SIZE.x
		all_cards_size = hand_size
	
	var offset := all_cards_size / 2
	
	for i in cards:
		var card : CartaNormal = cartasnode.get_child(i)
		var y_multiplier := hand_curve.sample(1.0 / (cards-1) * i)
		var rot_multiplier := rotation_curve.sample(1.0 / (cards-1) * i)
		if cards == 1:
			y_multiplier = 0.0
			rot_multiplier = 0.0
			offset = 0
		
		var final: Vector2 = Vector2((Carta.SIZE.x * i + final_x_sep * i)-offset,y_min + y_max * y_multiplier)
		
		card.snap_pos = final
		card.snap_rot = max_rotation_degrees * rot_multiplier
		card.Move(.1,final,max_rotation_degrees * rot_multiplier)


func _on_node_2d_child_exiting_tree(node: Node) -> void:
	AtualizarCartas()

func _on_control_cartaposta(carta: Variant) -> void:
	if carta.get_parent() == cartasnode:
		AtualizarCartas()
		return
	carta.get_parent().remove_child(carta)
	cartasnode.add_child(carta)
	AtualizarCartas()
