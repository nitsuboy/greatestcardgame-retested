## Classe base para todos os sistemas do ECS.
##
## Ciclo de vida gerenciado pelo WorldRunner:
## 1. WorldRunner._ready injeta world e replicator
## 2. WorldRunner chama init_system() (após todos os sistemas registrados)
## 3. A cada frame, WorldRunner._process chama update(delta)
## 4. Ao ser removido, cleanup() é chamado
##
## Sistemas podem se conectar a sinais do world (events, replicator)
## dentro de init_system().
@icon("res://scripts/core/icons/systemnode.svg")
class_name SystemNode
extends Node

var world: World
var replicator: Replicator


## Chamado uma vez após world e replicator serem injetados.
## Use para conectar sinais e inicializar dependências.
func init_system() -> void:
	pass


## Chamado a cada frame pelo WorldRunner.
## Use para lógica contínua (consultas, animações, etc).
func update(_delta: float) -> void:
	pass


## Chamado quando o sistema é removido da árvore.
## Use para limpar recursos e desconectar sinais.
func cleanup() -> void:
	pass
