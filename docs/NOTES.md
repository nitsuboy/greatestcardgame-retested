## Arquitetura Final (Híbrida + Server-Authoritative)

### Visão Geral — Dois Mundos

```
┌──────────────────────────────────────────────────────────────────────┐
│                                                                      │
│   SERVIDOR                    │              CLIENTE                 │
│   (World autoritativo)        │              (World sombra)          │
│                                                                      │
│ ┌─────────────────────────┐   │   ┌─────────────────────────────┐   │
│ │  PURE SYSTEMS           │   │   │  PURE SYSTEMS (CÓPIA)        │   │
│ │  (sem Node API)         │   │   │  (sem Node API)             │   │
│ │                         │   │   │                             │   │
│ │  TurnSystem             │   │   │  TurnSystem                 │   │
│ │  PlayCardSystem         │   │   │  PlayCardSystem             │   │
│ │  DrawSystem             │   │   │  DrawSystem                 │   │
│ │  ValidationSystem       │   │   │  ValidationSystem           │   │
│ │                         │   │   │                             │   │
│ │  Só mexem em:           │   │   │  Só mexem em:              │   │
│ │  CardComponent.zone_id  │   │   │  CardComponent (recebido)   │   │
│ │  CardComponent.face_up  │   │   │                             │   │
│ │  PlayerComponent.turn   │   │   │  ────────────────────────   │   │
│ │                         │   │   │  │ CLIENT-ONLY SYSTEMS │   │   │
│ │  ────────────────────   │   │   │  │ (com NodeRef)       │   │   │
│ │  │ REPLICATOR      │    │   │   │  │                     │   │   │
│ │  │ mark_dirty()    │───RPC─────→│  │ DragSystem          │   │   │
│ │  │ _sync_batch()   │    │   │   │  │ HoverSystem         │   │   │
│ │  └─────────────────┘    │   │   │  │ AnimationSystem     │   │   │
│ └─────────────────────────┘   │   │  │ ZoomSystem          │   │   │
│                                │   │  │                     │   │   │
│                                │   │  │ Usam NodeRef pra   │   │   │
│                                │   │  │ mexer no Node direto│   │   │
│                                │   │  └─────────────────────┘   │   │
│                                │   └─────────────────────────────┘   │
│                                │                                      │
│  RemoteAction recebe ações     │              ↑ gui_input            │
│  ←─── RPC "any_peer" ──────   │   ┌─────────────────────┐          │
│                                │   │ Card Node (Godot)   │          │
│                                │   │ entity_id, _world   │          │
│                                │   │ gui_input → EventBus│          │
│                                │   │ RemoteAction.send() │          │
│                                │   └─────────────────────┘          │
└──────────────────────────────────────────────────────────────────────┘
```

---

### O Que Cada System Faz

```
┌─────────────────────────────────────────────────────────────────────────┐
│ PURE SYSTEMS — rodam em Servidor + Cliente (idênticos)                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  [TurnSystem]                                                           │
│   ├── init: world.events.on_action_received.connect()                  │
│   ├── Controle: quem é o jogador atual, início/fim de turno             │
│   ├── Ações: recebe "end_turn" → passa turno no PlayerComponent       │
│   └── Node API? ❌ — só mexe em PlayerComponent.current_turn           │
│                                                                         │
│  [DrawSystem]                                                           │
│   ├── init: world.events.on_action_received.connect()                  │
│   ├── [Servidor] recebe "draw_card":                                   │
│   │    → world.create_entity()                                         │
│   │    → world.add_component(entity, CardComponent{zone_id: mão})     │
│   │    → Replicator.mark_dirty(entity, CardComponent)                  │
│   ├── [Cliente] recebe via Replicator: entidade + CardComponent        │
│   │    → detecta CardComponent novo → instancia Card.tscn (via Dealer)│
│   └── Node API? ❌ — cria entidade, Replicator sincroniza              │
│                                                                         │
│  [PlayCardSystem]                                                       │
│   ├── init: world.events.on_action_received.connect()                  │
│   ├── [Servidor] recebe "play_card":                                   │
│   │    → valida (é turno do jogador? carta jogável?)                    │
│   │    → CardComponent.zone_id = playzone                              │
│   │    → Replicator.mark_dirty(entity, CardComponent)                  │
│   └── Node API? ❌ — só valida e atualiza zone_id                      │
│                                                                         │
│  [ValidationSystem]                                                     │
│   ├── init: world.events.on_action_received.connect()                  │
│   ├── Regras: cor atual, valor atual, cartas especiais                 │
│   ├── "play_card" é válido? → true/false                               │
│   └── Node API? ❌ — lê CardComponent + TopCardComponent, compara     │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ CLIENT-ONLY SYSTEMS — rodam SÓ no cliente (com NodeRef)               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  [DragSystem]                                                           │
│   ├── init: world.events.on_card_input.connect()                       │
│   ├── update: world.query([DragState, NodeRef]).for_each()             │
│   │    → ref.node.position = get_global_mouse_position()               │
│   ├── drag_start: add_component(entity, DragState)                     │
│   │             → ref.node.scale = 1.2, z_index = 10                   │
│   ├── drag_end: remove_component(entity, DragState)                    │
│   │           → ref.node.scale = 1.0, z_index = 0                      │
│   │           → RemoteAction.send("play_card", {entity, zone})        │
│   └── Node API? ✅ — direto em ref.node.position, scale, etc.         │
│                                                                         │
│  [HoverSystem]                                                          │
│   ├── init: world.events.on_card_mouse_exited.connect()                │
│   ├── update: world.query([HoverState, NodeRef]).for_each()            │
│   │    → ref.node.scale = 1.1, z_index = 5                             │
│   └── Node API? ✅ — direto em ref.node                              │
│                                                                         │
│  [AnimationSystem]                                                      │
│   ├── init: world.events.on_component_added.connect()                  │
│   ├── CardComponent.zone_id mudou?                                     │
│   │    → ref.node.move(.2, new_pos)  (Tween)                          │
│   │    → ref.node.flip(face_up)                                        │
│   └── Node API? ✅ — Tween, animação, flip                            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

### Fluxo de uma Jogada Completa (Play Card)

```
CLIENTE (quem jogou)                   SERVIDOR                OUTROS CLIENTES
───────────────────                    ────────                ────────────────

Card.gui_input(event)
  ↓
DragSystem:
  ref.node.position = mouse_pos
  [arrasta livremente]
  ↓ (solta na DropZone)
RemoteAction.send("play_card",
  {entity: 42, zone: 5})
  ────────────────RPC────────────────→
                                       PlayCardSystem._on_action:
                                         valida (turno, regras)
                                         CardComponent.zone_id = 5
                                         mark_dirty(42, CardComponent)
                                       ────────────────RPC────────────────→
                                                                          Replicator._sync_batch:
                                       ←───────────────RPC────────────────   CardComponent.zone_id = 5
                                                                           AnimationSystem:
Replicator._sync_batch:                                                      ref.node.move(.2, playzone_pos)
  CardComponent.zone_id = 5                                                   ref.node.flip(true)
AnimationSystem:
  ref.node.move(.2, playzone_pos)
  ref.node.flip(true)
```

---

### O Que Cada Componente Significa

```
COMPONENT                      | ONDE É ESCRITO         | ONDE É LIDO
──────────────────────────────────────────────────────────────────────────
CardComponent                  | DrawSystem (servidor)   | PlayCardSystem, Validation
  .color, .value, .zone_id    | PlayCardSystem (serv)   | AnimationSystem (cliente)
  .face_up                    |                         | Dealer (instanciação)

DraggableComponent             | Dealer (instanciação)   | DragSystem (cliente)
  .locked                      | TurnSystem (servidor)   |

NodeRef                        | Card Node (ready)       | DragSystem, HoverSystem,
  .node: Node                  |                         | AnimationSystem (clientes)

DragState (marcador só existir)| DragSystem (cliente)    | DragSystem (cliente)

PlayableComponent              | Dealer (instanciação)   | PlayCardSystem

MouseComponent (entidade 0)    | Card Node (gui_input)   | DragSystem (cliente)

PositionComponent (se quiser)  | não usado no híbrido   | não usado no híbrido
```

---

### Arquivos Finais (O Que Fica e O Que Sai)

```
addons/ecs/                          ← framework ECS
├── core/
│   ├── world.gd                     ← World (RefCounted)
│   ├── entity_manager.gd            ← IDs compactos
│   ├── event_bus.gd                 ← Signals Godot
│   ├── query.gd                     ← Cardinalidade mínima
│   └── system_node.gd               ← Classe base System (Node)
├── storage/
│   └── sparse_set.gd                ← SoA storage
├── network/
│   ├── connection.gd                ← WebSocket wrapper (novo)
│   ├── replicator.gd                ← Server→Client sync (novo)
│   ├── remote_action.gd             ← Client→Server RPC (novo)
│   └── player_registry.gd           ← Jogadores (novo)
└── bridge/
    └── world_runner.gd              ← Node que roda World + descobre systems

scripts/game/                        ← seu jogo
├── components/
│   ├── card_component.gd            ← color, value, zone_id, face_up
│   ├── draggable_component.gd       ← locked
│   └── node_ref.gd                  ← .node: Node (só cliente!)
├── systems/
│   ├── pure/                        ← rodam em servidor + cliente
│   │   ├── turn_system.gd
│   │   ├── play_card_system.gd
│   │   ├── draw_system.gd
│   │   └── validation_system.gd
│   ├── client/                      ← rodam só no cliente
│   │   ├── drag_system.gd
│   │   ├── hover_system.gd
│   │   └── animation_system.gd
│   └── mixed/                       ← rodam nos dois mas com if
│       └── system_padrao.gd
├── card/
│   └── card.gd                      ← Card (Control) com gui_input
└── dealer.gd                        ← Cria cartas, instancia cenas

REMOVER:
- scripts/ecs_old/                   ← ECS antigo
- scripts/core/network_manager.gd     ← substituído por Connection + Replicator
- scripts/core/globals.gd             ← substituído por World eventos
- scripts/game/card/card_node_ref.gd  ← movido para components/node_ref.gd
- scripts/game/drag/systems/drag_system.gd (antigo) ← reescrito
- scripts/game/hover/ (antigo)       ← reescrito
- scripts/game_old/                   ← substituído
- project.godot autoloads: Players, Net, Globals ← só WorldRunner
```

---

### Regras de Ouro

1. **Pure Systems** nunca usam `Node`, `NodeRef`, nem chamam Godot API — só manipulam `Resource` components
2. **Client Systems** podem usar `NodeRef.node` à vontade — mas nunca enviam Node pelo RPC
3. **NodeRef** nunca é sincronizado pelo Replicator — é adicionado localmente no cliente quando a cena é instanciada
4. **Servidor nunca tem NodeRef** — se tentar, bug óbvio
5. **RemoteAction** é o único caminho cliente→servidor para ações de jogo