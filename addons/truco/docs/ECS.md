# ECS — Entity Component System

## Visão Geral

```
┌──────────────────────────────────────────────────────┐
│                    WorldRunner                        │
│  (Node — _ready injeta world e replicator nos filhos) │
│                                                       │
│  ├── World         ─── dados (entidades, componentes) │
│  ├── SystemNode    ─── lógica (sistemas filhos)       │
│  └── Replicator    ─── sincronização remota           │
└──────────────────────────────────────────────────────┘
```

O ECS tem três camadas:

| Camada | Classe | Arquivo | Propósito |
|--------|--------|---------|-----------|
| Storage | `SparseSet` | `ecs/storage/sparse_set.gd` | Array-of-structs denso por tipo de componente |
| Identidade | `EntityManager` | `ecs/storage/entity_manager.gd` | IDs com geração (generational index) |
| Orquestração | `World` | `ecs/world.gd` | Facade: criar/deletar entidades, add/remove/get componentes, queries |
| Query | `Query` | `ecs/query.gd` | Iteração sobre entidades com conjunto de componentes |
| Base de Componente | `Component` | `ecs/component.gd` | `Resource` com serialização `to_dict`/`from_dict` |
| Base de Sistema | `SystemNode` | `ecs/system_node.gd` | `Node` com hooks `init_system`, `update`, `cleanup` |

---

## SparseSet — Storage de Componentes

```
Arquivo: scripts/core/ecs/storage/sparse_set.gd
```

Estrutura de dados que armazena componentes de um **mesmo tipo** em arrays paralelas densas, com um array esparso de índice para lookup O(1).

### Layout em memória

```
_sparse (PackedInt32Array)     _dense (PackedInt32Array)     _data (Array[Resource])
┌─────────────────────────┐   ┌─────────────────────────┐   ┌──────────────────────┐
│  entity_id → dense_index│   │  [entity_A, entity_C]   │   │  [comp_A, comp_C]    │
│  -1 = não presente      │   │                         │   │                      │
│  N = índice no _dense   │   │  dense[0] = entity_A    │   │  data[0] = comp_A    │
│                         │   │  dense[1] = entity_C    │   │  data[1] = comp_C    │
│  sparse[entity_A] = 0   │   │                         │   │                      │
│  sparse[entity_C] = 1   │   │                         │   │                      │
│  sparse[entity_B] = -1  │   │                         │   │                      │
└─────────────────────────┘   └─────────────────────────┘   └──────────────────────┘
```

### Operações

**`add(entity, component)`**
1. `ensure_space(entity)` — redimensiona `_sparse` se necessário
2. Índice = `_dense.size()`
3. Append entity em `_dense`, component em `_data`
4. `_sparse[entity] = indice`

**`get_(entity)`**
1. Verifica `has(entity)` (assert)
2. `return _data[_sparse[entity]]` — O(1)

**`has(entity)`**
1. Verifica se entity está dentro do range de `_sparse`
2. Verifica se `_sparse[entity] >= 0` e `_dense[indice] == entity`

**`remove(entity)` — swap-with-last**
```
Antes:                    Depois (remove entity_A):
_sparse                   _sparse
  entity_A → 0              entity_A → -1
  entity_B → -1             entity_B → -1
  entity_C → 1              entity_C → 0  ← atualizado

_dense                    _dense
  [0] = entity_A            [0] = entity_C  ← entity_C move p/ idx 0
  [1] = entity_C            [1] = (removido)

_data                     _data
  [0] = comp_A              [0] = comp_C
  [1] = comp_C              [1] = (removido)
```

Swap-with-last: copia o último elemento para a posição removida, depois dá resize. Evita shifting — O(1) amortizado.

### Quando usar `has_component` antes de `get_component`

```gdscript
# ✅ Seguro — não crasha se storage não existe
if world.has_component(e, MeuComponent):
	var c = world.get_component(e, MeuComponent)

# ❌ CRASHA se storage de MeuComponent nunca foi criado
var c = world.get_component(e, MeuComponent)
# → "The key "res://scripts/..." did not exist in the dictionary"
```

O crash ocorre em `world.gd:56` — `_storages[type].get_(entity)`. Se `type` não tem storage (`_storages` não contém a chave), o acesso `_storages[type]` lança erro.

Sempre usar `world.has_component` como guarda — ele verifica `_storages.has(type)` antes de acessar.

### Propriedades

| Operação | Complexidade | Notas |
|----------|-------------|-------|
| `has` | O(1) | Dois array lookups + bounds check |
| `get_` | O(1) | Direto via sparse index |
| `add` | O(1) amortizado | Append no dense; possível resize do sparse |
| `remove` | O(1) | Swap-with-last no dense |
| `for_each` | O(n) | Itera o dense inteiro |

---

## EntityManager — IDs com Geração

```
Arquivo: scripts/core/ecs/storage/entity_manager.gd
```

Usa **generational index** para reutilizar IDs sem conflito.

### Formato do ID (packed integer)

```
Bits:  31 .. 30   29 .. 22    21 .. 0
	   [ unused ] [ geração ] [ índice ]

INDEX_BITS = 22  → max ~4M entidades
GEN_BITS   = 8   → 256 gerações por slot
GEN_SHIFT  = 22
```

`_pack(index, generation)` → `(generation << 22) | index`

### Ciclo de vida

```
create():
  1. Se _free_list não vazia → reusa índice
  2. Senão → append novo slot em _generations
  3. Incrementa living_count
  4. Retorna packed(entity_id)

destroy(entity):
  1. Incrementa geração no slot
  2. Adiciona índice à _free_list
  3. Decrementa living_count

exists(entity):
  1. unpack index + generation
  2. Verifica _generations[index] == generation
```

Entity IDs reciclados recebem nova geração, então `has_component` em entidades destruídas retorna falso naturalmente (o SparseSet checa `_dense[idx] == entity`, que falha pois o ID mudou).

---

## World — Orquestrador

```
Arquivo: scripts/core/ecs/world.gd
```

### Propriedades

```gdscript
var entities: EntityManager      # gerenciamento de IDs
var events: EventBus             # sinais do ECS + jogo
var _storages: Dictionary[Script, SparseSet]  # tipo → storage
var _query_cache: Dictionary     # cache de queries (String → Query)
var _systems: Dictionary[Script, SystemNode]  # tipo → sistema registrado
```

### Storage por Script exato

`_storages` é chaveado pelo `Script` (godot object) do componente:

```gdscript
func add_component(entity: int, component: Resource) -> void:
	var type = component.get_script()           # ← chave exata
	if not _storages.has(type):
		_storages[type] = SparseSet.new()
	_storages[type].add(entity, component)
```

**CRÍTICO**: `get_script()` retorna a classe EXATA. Herança NÃO funciona:

```gdscript
var base = BaseComponent.new()    # get_script → BaseComponent
var derived = DerivedComponent.new()  # get_script → DerivedComponent (NÃO BaseComponent)

world.add_component(e, derived)
world.has_component(e, BaseComponent)    # ❌ false — storage é DerivedComponent
world.has_component(e, DerivedComponent)  # ✅ true
```

### Queries com cache

```gdscript
func query(all: Array[Script] = []) -> Query:
	var key = PackedStringArray()
	for s in all:
		key.append(s.resource_path)
	var k = "\n".join(key)            # ← chave = resource_paths concatenados
	if not _query_cache.has(k):
		_query_cache[k] = Query.new(self, all)
	return _query_cache[k]
```

Queries com o mesmo conjunto de tipos compartilham a mesma instância de `Query`.

### Eventos

```gdscript
# ECS events
events.on_entity_created(entity)
events.on_entity_destroyed(entity)
events.on_component_added(entity, component_type)
events.on_component_removed(entity, component_type)

# Game events
events.on_card_input(entity_id, input_event)
events.on_card_dropped(entity_id, dropzone)
events.on_card_played(entity_id, played_by)
events.on_turn_changed(current_player, turn_number)
events.on_game_over(winner_id)
# ... veja event_bus.gd para a lista completa
```
Deve ser editado de acordo com a necessidade de eventos

---

## Query — Iteração sobre Múltiplos Componentes

```
Arquivo: scripts/core/ecs/query.gd
```

### Algoritmo

```
for_each(callback):
  1. Encontra o tipo de componente com MENOS entidades (smallest storage)
  2. Itera apenas esse storage
  3. Para cada entidade, verifica se possui TODOS os outros componentes
  4. Se sim, chama callback(entity, [comp0, comp1, ...])
```

### Exemplo

```gdscript
world.query([CardComponent, NodeRef, DraggableComponent]).for_each(
	func(e, comps):
		var card: CardComponent = comps[0]
		var node: NodeRef = comps[1]
		var drag: DraggableComponent = comps[2]
		node.node.position += Vector2(10, 0)
)
```

### Performance

- Itera o menor storage (otimização: entidades com DraggableComponent são minoria)
- Para cada entidade: N-1 `has_component` checks (O(1) cada)
- Total: O(min_storage_size × types)

---

## Component — Serialização

```
Arquivo: scripts/core/ecs/component.gd
```

### Hierarquia

```
Resource
  └── Component  (class_name, @abstract)
		├── CardComponent   (zone_id, face_up, play_order)
		├── DragState       (marca entidade sendo arrastada)
		├── DraggableComponent  (pode ser arrastada)
		├── ZoomableComponent   (pode ampliar)
		├── NodeRef         (referência ao Node, NÃO serializa)
		├── TurnComponent   (estado do turno)
		└── ... (componentes do jogo como UnoCardComponent)
```

### Serialização

`to_dict()` itera `get_property_list()` e exporta propriedades públicas (sem prefixo `_`), convertendo tipos:

| Tipo Godot | Representação |
|-----------|---------------|
| `int`, `float`, `String`, `bool` | Direto |
| `Vector2` | `{"x": v.x, "y": v.y}` |
| Outros | `str(value)` |

`from_dict(data)` restaura os valores pelo nome da propriedade.

`should_serialize()` — `NodeRef` retorna `false` (não faz sentido serializar uma referência a Node).

---

## SystemNode — Classe Base de Sistemas

```
Arquivo: scripts/core/ecs/system_node.gd
```

```gdscript
class_name SystemNode
extends Node

var world: World
var replicator: Replicator

func init_system() -> void:   # chamado após world/replicator injetados
	pass

func update(_delta: float) -> void:   # chamado a cada frame via _process
	pass

func cleanup() -> void:   # chamado ao destruir
	pass
```

### Ciclo de vida

```
WorldRunner._ready()
  ├── Para cada filho:
  │     child.world = world
  │     child.replicator = replicator
  │     world.register_system(child, child.get_script())
  │
  └── Para cada filho:
		child.init_system()

WorldRunner._process(delta)
  └── Para cada sistema:
		sys.update(delta)
```

`init_system()` é onde os sistemas se conectam a sinais:

```gdscript
# Exemplo: play_card_system.gd
func init_system() -> void:
	world.events.on_card_dropped.connect(_on_card_dropped)
	replicator.batch_applied.connect(_on_batch_applied)
```

---

## WorldRunner — Ponto de Entrada

```
Arquivo: scripts/core/ecs/world_runner.gd
```

### O que faz

1. Cria o `World`
2. Injeta `world` e `replicator` em todos os filhos `SystemNode`
3. Registra cada sistema no World (`world.register_system`)
4. Chama `init_system()` de cada filho (após TODOS estarem registrados)
5. A cada frame, chama `update(delta)` de todos os sistemas

### Por que `init_system` em dois loops?

```gdscript
# Loop 1: injeta dependências + registra
for child in get_children():
	child.world = world
	child.replicator = replicator
	world.register_system(child, child.get_script())

# Loop 2: inicializa (sistemas já podem se enxergar via world.get_system)
for child in get_children():
	child.init_system()
```

Isso garante que durante `init_system()`, qualquer sistema pode chamar `world.get_system(OutroSistema)` para obter referência a outro sistema — todos já estão registrados.

---

## Fluxo Completo

```
1. game.tscn é instanciado
2. WorldRunner._ready()
   ├── World.new()
   ├── Injeta world/replicator nos filhos
   ├── Registra sistemas (world.register_system)
   └── init_system() de cada sistema

3. Servidor:
   ├── Cria entidades, adiciona componentes
   ├── Push via Replicator.push_state()
   └── Batch enviado via RPC para clientes

4. Cliente:
   ├── Recebe batch
   ├── Replicator._apply_batch() → modifica World local
   └── Emite replicator.batch_applied
	   └── Sistemas reagem (ex: background_system muda cor)

5. A cada frame:
   └── WorldRunner._process(delta)
	   └── sys.update(delta) para cada sistema

6. Input:
   ├── Node visual → emite world.events.on_card_input
   └── InteractionSystem recebe → processa drag/zoom
```

---

## Patterns & Pitfalls

### Uso correto de `has_component`

Sempre antes de `get_component` para componentes que podem não existir:

```gdscript
# ✅
if world.has_component(e, MeuComponent):
	var c = world.get_component(e, MeuComponent)
```

### Composição, não herança

Como `_storages` é chaveado por Script exato, herança não funciona:

```gdscript
# ✅ Correto: múltiplos componentes na mesma entidade
world.add_component(e, CardComponent.new())
world.add_component(e, UnoCardComponent.new())

# ❌ Incorreto: herança não é detectada por queries/has_component
class UnoCardComponent extends CardComponent  # NÃO FAZER
```

### Sistemas acessando outros sistemas

```gdscript
var turn_sys = world.get_system(TurnSequenceSystem) as TurnSequenceSystem
```

Disponível apenas durante/após `init_system()` (todos os sistemas já registrados).

### EventBus vs Replicator.batch_applied

- **EventBus**: para eventos locais (input, mudanças de estado não replicadas)
- **Replicator.batch_applied**: para reação a mudanças de estado replicadas (deve ser usado no lugar de eventos locais do servidor para garantir que cliente também processe)

### Nodes não são componentes

`NodeRef` é um componente especial que guarda referência ao Node visual. Nunca coloque nodes diretamente em arrays de componentes — use `NodeRef` como ponteiro.
