# TRUCO: ECS Multiplayer Framework for Card Games

![Godot](https://img.shields.io/badge/engine-Godot%204-blue?logo=godot-engine&logoColor=white)
![Language](https://img.shields.io/badge/language-GDScript-orange)
![Status](https://img.shields.io/badge/status-in%20development-yellow)
![Version](https://img.shields.io/badge/version-v1.0.2-green)
![Architecture](https://img.shields.io/badge/architecture-ECS%2BOOP-purple)
[![Tests](https://github.com/nitsuboy/TRUCO-godot/actions/workflows/tests.yml/badge.svg)](https://github.com/nitsuboy/TRUCO-godot/actions/workflows/tests.yml)

*TRUCO: Toolkit para Reutilização e Unificação de Componentes de Objetos para Jogos de Cartas*

A Godot 4 addon providing an ECS multiplayer framework for card games with hybrid ECS + OOP architecture and clear core/game separation.

---

## Installation

1. Copy `addons/truco/` into your project's `addons/` directory
2. Enable **TRUCO** in Project Settings → Plugins
3. The plugin automatically registers these autoloads:
   - **Conn** — WebSocket connection management (`ecs_connection.gd`)
   - **Players** — Player registry (`player_registry.gd`)
   - **Sync** — Sync barrier (`sync_barrier.gd`)
   - **Remote** — Remote action RPC (`remote_action.gd`)
   - **Zones** — Zone registry (`zone_registry.gd`)

---

## Architecture

### Folder Structure

```
addons/truco/           # Addon — framework code only
├── core/               # Reusable framework for any card game
│   ├── ecs/            # ECS (Entity-Component-System)
│   ├── network/        # Multiplayer sync (Replicator)
│   ├── turn/           # Turn engine
│   ├── choice/         # Player choice system
│   ├── input/          # Input (click, drag, drop, hover, zoom)
│   ├── zone/           # Drop zones (2D and 3D)
│   ├── rule/           # Rule system (Rule, RulePack)
│   ├── card/           # Base card components
│   └── player/         # Player components
├── icons/              # Editor icons for custom types
├── truco.gd            # EditorPlugin
└── plugin.cfg          # Plugin config
scripts/game/           # Game-specific implementation
├── components/         # Game components
├── systems/            # Game systems
├── rules/              # Validation rules
├── card/               # Card visuals
└── ui/                 # Game UI
```

Drop zones support both 2D and 3D: `DropZone` (2D, registered as the plugin's custom type), `DropZone2D` and `DropZone3D` (with animated drop: arc, jitter and card stack height).

### Core vs Game Separation

| Directory | Purpose | Cannot depend on |
|-----------|---------|------------------|
| `addons/truco/core/` | Reusable framework for any card game | `scripts/game/` |
| `scripts/game/` | Game-specific implementation | — |

### Scene Overview

```
game.tscn
├── Game (game.gd) — initialization, game UI
├── WorldRunner (world_runner.gd)
│   ├── World (world.gd) — ECS core
│   ├── Replicator (replicator.gd) — multiplayer sync
│   ├── PlayerChoiceSystem — player choices
│   ├── InteractionSystem — input (drag, zoom)
│   ├── HoverSystem — card hover
│   ├── TurnMachine — turn engine
│   ├── ValidationSystem — play validation
│   ├── CardSpawnerSystem — card spawn
│   ├── DropSystem — drop detection
│   └── ... (game-specific systems)
└── front (CanvasLayer)
    └── ChoiceUI (dynamically instantiated)
```

---

## ECS — Entity Component System

### Overview

```
┌──────────────────────────────────────────────────────┐
│                    WorldRunner                        │
│  (Node — _ready injects world/replicator into children)│
│                                                       │
│  ├── World         ─── data (entities, components)    │
│  ├── SystemNode    ─── logic (child systems)          │
│  └── Replicator    ─── remote sync                    │
└──────────────────────────────────────────────────────┘
```

### Layers

| Layer | Class | File | Purpose |
|-------|-------|------|---------|
| Storage | `SparseSet` | `ecs/storage/sparse_set.gd` | Dense array-of-structs per component type |
| Identity | `EntityManager` | `ecs/storage/entity_manager.gd` | IDs with generational index |
| Orchestration | `World` | `ecs/world.gd` | Facade: create/delete entities, add/remove/get components, queries |
| Query | `Query` | `ecs/query.gd` | Iterate entities with component set |
| Component | `Component` | `ecs/component.gd` | `Resource` with `to_dict`/`from_dict` serialization (`int`, `float`, `String`, `bool`, `Vector2`, `Vector3`, `Array`) |
| System | `SystemNode` | `ecs/system_node.gd` | `Node` with `init_system`, `update`, `cleanup` hooks |

> `SparseSet` indexes its sparse array with `entity_id & INDEX_MASK` (22-bit entity index) instead of the raw entity ID. This keeps memory bounded and lookups cache-friendly even as generational IDs grow from heavy create/delete cycles.

### World

```gdscript
# Create entity
var e = world.create_entity()

# Components
world.add_component(e, MyComponent.new())
world.has_component(e, MyComponent)  # always check before get_component!
var c = world.get_component(e, MyComponent)
world.remove_component(e, MyComponent)

# Query
world.query([ComponentA, ComponentB]).for_each(func(e, comps):
    var a: ComponentA = comps[0]
    var b: ComponentB = comps[1]
)
```

### Component Inheritance does NOT work

Storage is keyed by exact `Script` (`_storages[component.get_script()]`):

```gdscript
class Advanced extends BaseComponent
world.has_component(e, BaseComponent)  # false!
world.query([BaseComponent])           # does not find Advanced
```

Use composition — multiple components on the same entity.

### Core Components

| Component | Purpose |
|-----------|---------|
| `CardComponent` | `zone_id`, `face_up`, `play_order` — universal card identifier |
| `NodeRef` | Reference to visual Node in the scene tree |
| `DragState` | Marks entity as being dragged |
| `DraggableComponent` | Card can be dragged |
| `ZoomableComponent` | Card can be zoomed |
| `ClickableComponent` | Card can be clicked (emits `on_card_clicked`) |
| `LockState` | Locks interaction locally (does not serialize) |
| `HoverableComponent` | Card reacts to hover (with `locked` flag) |
| `SyncPositionComponent` | Syncs a 3D position over the network |

### CardData

```gdscript
class CardData extends Resource:
    var components: Array[Component] = []
```

Serializable `Resource`. When creating a card, the spawner iterates `card_data.components` and adds each to the entity.

### Lifecycle

```
1. game.tscn is instantiated
2. WorldRunner._ready()
   ├── Creates World
   ├── Injects world/replicator into child SystemNodes
   ├── Registers systems (world.register_system)
   └── Calls init_system() on each system

3. Server:
   ├── Creates entities, adds components
   ├── push_state() via Replicator → batch sent via RPC
   └── Client applies batch → emits batch_applied

4. Every frame:
   └── WorldRunner._process(delta) → sys.update(delta) for each system

5. Input:
   ├── Visual Node → emits world.events.on_card_input
   └── InteractionSystem receives → processes drag/zoom
```

---

## Multiplayer / Sync

### Replicator (`core/network/replicator.gd`)

Syncs ECS state via RPCs:

1. Server modifies components locally
2. `Replicator.push_state()` → creates a batch with the changes
3. Batch sent via RPC to all clients
4. Client receives and applies via `_apply_batch()`
5. After applying, emits `replicator.batch_applied`

Systems MUST use `replicator.batch_applied` instead of local server events to ensure server and client process the same changes.

```gdscript
# Server: after modifying components
Replicator.push_state()

# Client: process changes
replicator.batch_applied.connect(_on_batch_applied)
```

### Rule: use `replicator.batch_applied`, not local events

```gdscript
# ✅ Correct
func init_system() -> void:
    replicator.batch_applied.connect(_on_batch_applied)

# ❌ Incorrect — runs only on server, client sees nothing
func update(_delta: float) -> void:
    if not multiplayer.is_server():
        return
```

### RemoteAction (`core/network/remote_action.gd`) — autoload `Remote`

Named-action RPC. Supports both styles:

```gdscript
# Signal API (all peers)
Remote.action_received.connect(_on_action)
func _on_action(sender_id: int, action: String, data: Dictionary) -> void: ...

# Handler API (server-side routing)
Remote.on("play_card", _on_play_card)
Remote.off("play_card", _on_play_card)
```

- `send(action, data)` — client → server (also routes locally when server)
- `broadcast(action, data)` — server → all peers
- `send_to(peer_id, action, data)` — server → specific peer

### UDP Discovery (`core/network/udp_discovery.gd`)

LAN server discovery.

---

## Turns

### TurnMachine (`core/turn/turn_machine.gd`)

Generic turn engine:
- Card locks — prevent interaction outside active turn
- Hand visibility — show/hide active player's hand
- Turn phases — managed by state

Virtual hooks available to subclasses (server side):
- `_on_phase_arrived(phase)` — fired on every synced turn update
- `_on_phase_changed(old_phase, new_phase)` — fired only when the phase changes
- `_on_player_changed(player_id)` — fired when the active player changes during an action phase

Game-specific systems extend the machine with custom sequences.

---

## Validation

### Rule System

Validation rules (not inline in systems):

```gdscript
class_name BaseRule extends RefCounted

func get_id() -> String:
	return "rule_id"

func validate(entity_id: int, target_zone: DropZone, context: Dictionary) -> bool:
    return true
```

### RulePack

```gdscript
var rule_pack = RulePack.new()
rule_pack.rules = [
    preload("res://scripts/game/rules/my_rule.gd").new(),
]
```

---

## Input

### InteractionSystem (`core/input/interaction_system.gd`)

Input flow:

1. `card.gd` detects mouse events → `world.events.on_card_input(entity_id, event)`
2. `InteractionSystem._on_card_input()` decides if click, drag or zoom
3. During drag, uses duck-typing: `parent.move_card(ref.node)`

Interaction components (`ClickableComponent`, `DraggableComponent`, `ZoomableComponent`) are checked in that order. A card with `ClickableComponent` emits `world.events.on_card_clicked(entity_id, dropzone)` instead of starting a drag. Cards blocked by `LockState` (or a component with `locked == true`) ignore input.

`ClickSystem` (`core/input/click_system.gd`) listens to `on_card_clicked` and sends a `"play_card"` action via `Remote`.

The core cannot know about game classes (`PlayerHand`, `Card`). Uses duck-typing to call game methods:

```gdscript
var parent = ref.node.get_parent()
if parent and parent.has_method("move_card"):
	parent.move_card(ref.node)
```

---

## Choices

### PlayerChoiceSystem (`core/choice/player_choice_system.gd`)

Generic system for requesting choices from players:

- `request_choice(player_id, type, data)` — server requests a choice
- `choice_received` — emitted when player responds (or timeout)
- `choice_ui_requested` — emitted for the game to open the appropriate UI

```gdscript
choice_sys.choice_ui_requested.connect(
	func(request_id: String, type: String, data: Dictionary):
		ChoiceUI.open(request_id, type, data, $front)
)
```

---

## System Events

| Event | Emitter | Purpose |
|-------|---------|---------|
| `on_card_input(entity_id, event)` | Card visual → `world.events` | Card input |
| `on_card_clicked(entity_id, dropzone)` | InteractionSystem → `world.events` | Card clicked |
| `on_card_dropped(entity_id, dropzone)` | InteractionSystem → `world.events` | Card dropped on zone |
| `on_game_entity_ready(entity_id)` | GameSetupSystem → `world.events` | Game entity created |
| `choice_ui_requested(request_id, type, data)` | PlayerChoiceSystem | Open choice UI |
| `batch_applied(entries)` | Replicator | Replication batch applied |

Truco game signals (optional, unused by the base game): `on_player_action_phase`, `on_truco_call`, `on_truco_response`, `on_round_won`, `on_hand_won`, `on_game_won`.

---

## Hotspots

| File | Function | Modify To |
|------|----------|-----------|
| `core/ecs/world.gd` | ECS World | Storage, queries, systems |
| `core/ecs/storage/sparse_set.gd` | SparseSet | Component storage |
| `core/ecs/storage/entity_manager.gd` | EntityManager | Entity IDs |
| `core/ecs/component.gd` | Component | New components |
| `core/ecs/system_node.gd` | SystemNode | System base |
| `core/network/replicator.gd` | Replicator | Multiplayer sync |
| `core/turn/turn_machine.gd` | TurnMachine | Turn engine |
| `core/rule/rule.gd` | Rule | Validation rules |
| `core/choice/player_choice_system.gd` | PlayerChoiceSystem | Player choices |
| `core/input/interaction_system.gd` | InteractionSystem | Card input |
| `game/systems/` | Game systems | Game-specific logic |

## Quick Links

- [ECS Design](addons/truco/docs/ECS.md)
- [Framework Overview](addons/truco/docs/FRAMEWORK.md)


## Requirements

- Godot 4.x
- GDScript

