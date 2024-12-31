@tool
extends Node2D

class_name Mao

@export var num_cartas:int =0 
@export var p0:Vector2i
@export var p1:Vector2i
@export var p2:Vector2i
@export var evoce:bool = true

var canvas_item:RID

var carta = preload("res://scenes/card_normal.tscn")
var points = []
var points_nodes = []

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if evoce:
		$"botoes".visible = true
		$"nome jogador".visible = false
		$"pontos2".visible = false
	else :
		$"botoes".visible = false
		$"nome jogador".visible = true
		$"pontos2".visible = true
		$"pontos".visible = false
	for i in num_cartas+1:
		var nodes = Node2D.new()
		nodes.position = _quadratic_bezier(p0,p1,p2,i*(1.0/(num_cartas+1)))
		nodes.rotation = ((i*(1.0/(num_cartas+1)))*.6) - .3
		add_child(nodes)
		points_nodes.append(nodes)
	for i in num_cartas:
		var c :CartaNormal= carta.instantiate()
		c.scale = Vector2i.ONE * .23
		c.carta_tipo = "verde"
		points_nodes[i+1].add_child(c)

func _process(delta: float) -> void:
	queue_redraw()

# daqui pra baixo vai ser futuramente deletado

func _enter_tree() -> void:
	canvas_item = RenderingServer.canvas_item_create()
	for i in num_cartas+1:
		points.append(_quadratic_bezier(p0,p1,p2,i*(1.0/(num_cartas+1))))
	print(points)
	RenderingServer.canvas_item_set_parent(canvas_item, get_canvas_item())

func _exit_tree() -> void:
	RenderingServer.canvas_item_clear(canvas_item)
	canvas_item = RID()

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1,t)
	return r

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	for i in num_cartas:
		draw_rect(Rect2i(points[i+1].x,points[i+1].y,50,-142),Color.GREEN)
		draw_rect(Rect2i(points[i+1].x,points[i+1].y,-50,-142),Color.GREEN,)
	draw_circle(p0,5,Color.RED)
	draw_circle(p1,5,Color.RED)
	draw_circle(p2,5,Color.RED)
