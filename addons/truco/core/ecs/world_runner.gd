## Ponto de entrada do ECS. Deve ser o pai de todos os sistemas na scene tree.
##
## Funcionamento em _ready():
## 1. Cria o World
## 2. Injeta world e replicator em todos os filhos SystemNode
## 3. Registra cada sistema no World (world.register_system)
## 4. Chama init_system() de cada sistema
##
## A injeção é feita em dois loops para garantir que durante
## init_system() todos os sistemas já estejam registrados e
## possam se referenciar via world.get_system(OutroSistema).
class_name WorldRunner
extends Node

@export var replicator: Replicator
var world: World
var _system_nodes: Array[SystemNode]


func _ready() -> void:
	world = World.new()

	# Loop 1: injeta dependências e registra sistemas
	for child in get_children():
		child.world = world
		child.replicator = replicator
		world.register_system(child, child.get_script())
		_system_nodes.append(child)

	# Loop 2: inicializa (todos os sistemas já registrados)
	for child in get_children():
		child.init_system()


func _process(delta: float) -> void:
	for sys in _system_nodes:
		sys.update(delta)
