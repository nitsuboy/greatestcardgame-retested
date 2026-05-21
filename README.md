# TRUCO: Toolkit para Reutilização e Unificação de Componentes de Objetos para Jogos de Cartas

![Godot](https://img.shields.io/badge/engine-Godot%204-blue?logo=godot-engine&logoColor=white)
![Language](https://img.shields.io/badge/language-GDScript-orange)
![Status](https://img.shields.io/badge/status-in%20development-yellow)
![Version](https://img.shields.io/badge/version-v1.0.0-green)
![Architecture](https://img.shields.io/badge/architecture-ECS%2BOOP-purple)

Framework ECS multiplayer em Godot 4 com arquitetura híbrida ECS + OOP e separação core/game.

---

## Arquitetura

### Estrutura de Pastas

```
scripts/
├── core/           # Framework reutilizável para qualquer jogo de cartas
│   ├── ecs/        # ECS (Entity-Component-System)
│   ├── network/    # Sincronização multiplayer (Replicator)
│   ├── turn/       # Engine de turnos
│   ├── choice/     # Sistema de escolhas do jogador
│   ├── input/      # Input (drag, drop, hover, zoom)
│   ├── zone/       # Zonas de drop
│   ├── rule/       # Sistema de regras (BaseRule, RulePack)
│   ├── card/       # Componentes base de carta
│   └── player/     # Componentes de jogador
├── game/           # Implementação específica do jogo
│   ├── components/ # Componentes do jogo
│   ├── systems/    # Sistemas do jogo
│   ├── rules/      # Regras de validação
│   ├── card/       # Visual da carta
│   └── ui/         # Interface do jogo
└── utils/          # Utilitários
```

### Separação Core vs Game

| Diretório | Propósito | Não pode depender de |
|-----------|-----------|---------------------|
| `scripts/core/` | Framework reutilizável para qualquer jogo de cartas | `scripts/game/` |
| `scripts/game/` | Implementação específica | — |

### Visão Geral da Cena

```
game.tscn
├── Game (game.gd) — inicialização, UI do jogo
├── WorldRunner (world_runner.gd)
│   ├── World (world.gd) — ECS core
│   ├── Replicator (replicator.gd) — sincronização multiplayer
│   ├── PlayerChoiceSystem — escolhas do jogador
│   ├── InteractionSystem — input (arrastar, zoom)
│   ├── HoverSystem — hover de cartas
│   ├── TurnMachine — engine de turnos
│   ├── ValidationSystem — validação de jogadas
│   ├── CardSpawnerSystem — spawn de cartas
│   ├── DropSystem — detecção de drop
│   └── ... (sistemas específicos do jogo)
└── front (CanvasLayer)
    └── ChoiceUI (instanciado dinamicamente)
```

---

## ECS — Entity Component System

### Visão Geral

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

### Camadas

| Camada | Classe | Arquivo | Propósito |
|--------|--------|---------|-----------|
| Storage | `SparseSet` | `ecs/storage/sparse_set.gd` | Array-of-structs denso por tipo de componente |
| Identidade | `EntityManager` | `ecs/storage/entity_manager.gd` | IDs com generational index |
| Orquestração | `World` | `ecs/world.gd` | Facade: criar/deletar entidades, add/remove/get componentes, queries |
| Query | `Query` | `ecs/query.gd` | Iteração sobre entidades com conjunto de componentes |
| Componente | `Component` | `ecs/component.gd` | `Resource` com serialização `to_dict`/`from_dict` |
| Sistema | `SystemNode` | `ecs/system_node.gd` | `Node` com hooks `init_system`, `update`, `cleanup` |

### World

```gdscript
# Criar entidade
var e = world.create_entity()

# Componentes
world.add_component(e, MeuComponente.new())
world.has_component(e, MeuComponente)  # sempre usar antes de get_component!
var c = world.get_component(e, MeuComponente)
world.remove_component(e, MeuComponente)

# Query
world.query([ComponentA, ComponentB]).for_each(func(e, comps):
    var a: ComponentA = comps[0]
    var b: ComponentB = comps[1]
)
```

### ⚠️ Herança de Component NÃO funciona

Storage é chaveado por `Script` exata (`_storages[component.get_script()]`):

```gdscript
# ❌ Herança não é detectada
class Avancado extends BaseComponent
world.has_component(e, BaseComponent)  # false!
world.query([BaseComponent])           # não encontra Avancado

# ✅ Use composição — múltiplos componentes na mesma entidade
world.add_component(e, BaseComponent.new())
world.add_component(e, AvancadoComponent.new())
```

### Componentes do Core

| Componente | Propósito |
|------------|-----------|
| `CardComponent` | `zone_id`, `face_up`, `play_order` — identificador universal de carta |
| `NodeRef` | Referência ao Node visual na scene tree |
| `DragState` | Marca entidade sendo arrastada |
| `DraggableComponent` | Carta pode ser arrastada |
| `ZoomableComponent` | Carta pode ser ampliada (zoom) |

### CardData

```gdscript
class CardData extends Resource:
    var components: Array[Component] = []
```

`Resource` serializável. Ao criar uma carta, o sistema de dealer itera `card_data.components` e adiciona cada um à entidade.

### Ciclo de Vida

```
1. game.tscn é instanciado
2. WorldRunner._ready()
   ├── Cria World
   ├── Injeta world/replicator nos filhos SystemNode
   ├── Registra sistemas (world.register_system)
   └── init_system() de cada sistema

3. Servidor:
   ├── Cria entidades, adiciona componentes
   ├── push_state() via Replicator → batch enviado via RPC
   └── Cliente aplica batch → emite batch_applied

4. A cada frame:
   └── WorldRunner._process(delta) → sys.update(delta) para cada sistema

5. Input:
   ├── Node visual → emite world.events.on_card_input
   └── InteractionSystem recebe → processa drag/zoom
```

---

## Multiplayer / Sincronização

### Replicator (`core/network/replicator.gd`)

Sincroniza estado do ECS via RPCs:

1. Servidor modifica componentes localmente
2. `Replicator.push_state()` → cria um batch com as mudanças
3. Batch enviado via RPC para todos os clientes
4. Cliente recebe e aplica via `_apply_batch()`
5. Após aplicar, emite `replicator.batch_applied`

Sistemas DEVEM usar `replicator.batch_applied` em vez de eventos locais do servidor para garantir que servidor e cliente processem as mesmas mudanças.

```gdscript
# Servidor: após modificar componentes
Replicator.push_state()

# Cliente: processar mudanças
replicator.batch_applied.connect(_on_batch_applied)
```

### Regra: usar `replicator.batch_applied`, não eventos locais

```gdscript
# ✅ Correto
func init_system() -> void:
    replicator.batch_applied.connect(_on_batch_applied)

# ❌ Incorreto — só roda no servidor, cliente não vê
func update(_delta: float) -> void:
    if not multiplayer.is_server():
        return
```

### UDP Discovery (`core/network/udp_discovery.gd`)

Descoberta de servidores LAN.

---

## Turnos

### TurnMachine (`core/turn/turn_machine.gd`)

Engine genérica de turnos:

- `locks[entity_id] = bool` — controle de interação por entidade
- `hand_hooks[entity_id] = Vector2` — posição de animação da mão
- Fases de turno gerenciadas por estados

Sistemas específicos do jogo estendem a máquina com sequências próprias.

---

## Validação

### ValidationSystem + Rules

Sistema de validação baseado em regras (não inline nos sistemas):

```gdscript
class_name BaseRule extends RefCounted

func get_id() -> String:
    return "rule_id"

func validate(entity_id: int, target_zone: DropZone, context: Dictionary) -> bool:
    return true  # true = jogada válida
```

O `context` é populado pelo `ValidationSystem` com dados da carta, zona de destino, e referência ao próprio sistema de validação.

### RulePack

```gdscript
var rule_pack = RulePack.new()
rule_pack.rules = [
    preload("res://scripts/game/rules/minha_rule.gd").new(),
]
```

---

## Input

### InteractionSystem (`core/input/interaction_system.gd`)

Fluxo de input:

1. `card.gd` detecta eventos de mouse → `world.events.on_card_input(entity_id, event)`
2. `InteractionSystem._on_card_input()` decide se é drag ou zoom
3. Durante drag, usa duck-typing: `parent.move_card(ref.node)`

O core não pode saber sobre classes do jogo (`PlayerHand`, `Card`). Usa duck-typing para chamar métodos do game:

```gdscript
var parent = ref.node.get_parent()
if parent and parent.has_method("move_card"):
    parent.move_card(ref.node)
```

---

## Escolhas

### PlayerChoiceSystem (`core/choice/player_choice_system.gd`)

Sistema genérico para solicitar escolhas dos jogadores:

- `request_choice(player_id, type, data)` — servidor solicita escolha
- `choice_received` — emitido quando jogador responde (ou timeout)
- `choice_ui_requested` — emitido para que o jogo abra a UI apropriada

```gdscript
choice_sys.choice_ui_requested.connect(
    func(request_id: String, type: String, data: Dictionary):
        ChoiceUI.open(request_id, type, data, $front)
)
```

---

## Eventos do Sistema

| Evento | Emissor | Propósito |
|--------|---------|-----------|
| `on_card_input(entity_id, event)` | Card visual → `world.events` | Input de carta |
| `on_card_dropped(entity_id, dropzone)` | InteractionSystem → `world.events` | Carta solta em zona |
| `on_game_entity_ready(entity_id)` | GameSetupSystem → `world.events` | Entidade do jogo criada |
| `choice_ui_requested(request_id, type, data)` | PlayerChoiceSystem | Abrir UI de escolha |
| `batch_applied(entries)` | Replicator | Batch de replicação aplicado |

---

## Hotspots

| Arquivo | Função | Modificar Para |
|---------|--------|---------------|
| `core/ecs/world.gd` | ECS World | Storage, queries, sistemas |
| `core/ecs/storage/sparse_set.gd` | SparseSet | Storage de componentes |
| `core/ecs/storage/entity_manager.gd` | EntityManager | IDs de entidades |
| `core/ecs/component.gd` | Component | Novos componentes |
| `core/ecs/system_node.gd` | SystemNode | Base de sistemas |
| `core/network/replicator.gd` | Replicator | Sincronização multiplayer |
| `core/turn/turn_machine.gd` | TurnMachine | Engine de turnos |
| `core/rule/rule.gd` | BaseRule | Regras de validação |
| `core/choice/player_choice_system.gd` | PlayerChoiceSystem | Escolhas do jogador |
| `core/input/interaction_system.gd` | InteractionSystem | Input de cartas |
| `game/systems/` | Sistemas do jogo | Lógica específica |

---

## Quick Links

- [ECS Design](docs/ECS.md)
- [Framework Overview](docs/FRAMEWORK.md)
- [Git Conventions](docs/GIT.md)

---

## Requisitos

- Godot 4.x
- GDScript

---

## Status

v1.0.0 — Em desenvolvimento
