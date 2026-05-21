# Framework ECS Multiplayer para Jogos de Carta

## Arquitetura

```
game.tscn
├── Game (game.gd) — inicialização, UI do jogo
├── WorldRunner (world_runner.gd)
│   ├── World (world.gd) — ECS core
│   ├── Replicator (replicator.gd) — sincronização multiplayer
│   ├── PlayerChoiceSystem — sistema genérico de escolhas (cor, alvo, etc)
│   ├── InteractionSystem — input de cartas (arrastar, zoom)
│   ├── HoverSystem — hover de cartas
│   ├── TurnMachine / TurnSequenceSystem — engine de turnos
│   ├── ValidationSystem — validação de jogadas via rules
│   ├── CardSpawnerSystem — spawn de cartas no mundo
│   ├── DealerSystem — distribuição de cartas
│   ├── EffectSystem — efeitos de cartas (coringa, comprar, pular)
│   ├── DropSystem — detecção de drop em zonas
│   ├── BotSystem — jogador automático
│   ├── BackgroundSystem — cor de fundo
│   └── ... (outros sistemas específicos do jogo)
└── front (CanvasLayer)
	└── ChoiceUI (instanciado dinamicamente)
```

### Separação Core vs Game

| Diretório | Propósito | Não pode depender de |
|-----------|-----------|---------------------|
| `scripts/core/` | Framework reutilizável para qualquer jogo de cartas | `scripts/game/` |
| `scripts/game/` | Implementação específica (UNO) | — |

---

## ECS (Entity-Component-System)

### World (`scripts/core/ecs/world.gd`)

Gerencia entidades, componentes e queries.

```gdscript
# Criar entidade
var e = world.create_entity()

# Adicionar/remover/consultar componentes
world.add_component(e, MeuComponente.new())
var c = world.get_component(e, MeuComponente)
world.remove_component(e, MeuComponente)
world.has_component(e, MeuComponente)  # sempre use antes de get_component!

# Query
world.query([ComponentA, ComponentB]).for_each(func(e, comps):
	var a: ComponentA = comps[0]
	var b: ComponentB = comps[1]
)
```

### CRÍTICO: Herança de Component NÃO funciona

Storage é chaveado por `Script` exata em `_storages[component.get_script()]`. Isso significa:

```gdscript
# ❌ NÃO FUNCIONA
class MeuComponente extends Component
class MeuComponenteAvancado extends MeuComponente
world.has_component(e, MeuComponente)        # false se o componente for MeuComponenteAvancado!
world.query([MeuComponente])                 # não encontra MeuComponenteAvancado

# ✅ Funciona — use composição
class MeuComponente extends Component
class OutroComponente extends Component
world.add_component(e, MeuComponente.new())
world.add_component(e, OutroComponente.new())
```

### Componentes do Core

| Componente | Propósito |
|------------|-----------|
| `CardComponent` | `zone_id`, `face_up`, `play_order` — identificador universal de carta |
| `NodeRef` | Referência ao Node visual na scene tree |
| `DragState` | Marca entidade sendo arrastada |
| `DraggableComponent` | Carta pode ser arrastada |
| `ZoomableComponent` | Carta pode ser ampliada (zoom) |

### Componentes do Game (UNO)

| Componente | Propósito |
|------------|-----------|
| `UnoCardComponent` | `card_name`, `color`, `value` — dados específicos UNO |

### CardData

```gdscript
class CardData extends Resource:
	var components: Array[Component] = []
```

É um `Resource` serializável (pode ser salvo em `.tres`). Ao criar uma carta, o `DealerSystem` itera `card_data.components` e adiciona cada um à entidade.

### CardData do Game

```gdscript
class UnoCardData extends CardData:
	var card_name: String
	var card_color: int
	var card_value: int
```

AO CRIAR UMA ENTIDADE de carta, o dealer gera tanto `CardComponent` (core) quanto `UnoCardComponent` (game). Ambos vivem na mesma entidade:

```
Entidade carta:
  ├── CardComponent (zone_id, face_up, play_order)
  ├── NodeRef (referência ao visual)
  ├── DraggableComponent (se aplicável)
  └── UnoCardComponent (color, value, card_name)
```

---

## Multiplayer / Sincronização

### Replicator (`scripts/core/network/replicator.gd`)

Sincroniza estado do ECS via RPCs. O fluxo é:

1. Servidor modifica componentes localmente
2. Servidor chama `Replicator.push_state()` para criar um batch
3. Batch é enviado via RPC para todos os clientes
4. Cliente recebe e aplica via `_apply_batch()`
5. Após aplicar, emite `replicator.batch_applied`

```gdscript
# Servidor: após modificar componentes
Replicator.push_state()

# Cliente: processar mudanças
replicator.batch_applied.connect(_on_batch_applied)
```

### Regra: usar `replicator.batch_applied`, não eventos locais

Sistemas que reagem a mudanças de estado DEVEM usar `replicator.batch_applied` em vez de eventos locais do servidor. Isso garante que servidor e cliente processem as mesmas mudanças da mesma forma.

```gdscript
# ✅ Correto
func init_system() -> void:
	replicator.batch_applied.connect(_on_batch_applied)

func _on_batch_applied(entries: Array) -> void:
	for entry in entries:
		if entry.type == "UnoCardComponent":
			var comp: UnoCardComponent = load(entry.type).new()
			# processa...

# ❌ Incorreto — sistema só roda no servidor, cliente não vê
func update(_delta: float) -> void:
	if not multiplayer.is_server():
		return
	# modifica componentes sem replicar para cliente
```

### Sincronização de Locks e Turnos

- `TurnMachine` sincroniza `locks` (impede interação fora do turno) e `hand_hooks` (animação de mão)
- Locks só são atualizados quando o batch contém `TurnComponent` — cartas jogadas podem ficar com locks stale até o próximo batch de turno
- `SyncBarrier._process()` tem guarda de peer ativo — não crasha ao desconectar

### Batch Processing — batches separados por tipo

`replicator.batch_applied` processa entradas em batches separados por tipo de componente. Exemplo: `UnoCardComponent.resource_path` e `CardComponent.resource_path` chegam em batches diferentes.

---

## Input (InteractionSystem)

### Fluxo de Input

1. `card.gd` detecta eventos de mouse e emite `world.events.on_card_input(entity_id, event)`
2. `InteractionSystem._on_card_input()` decide se é drag ou zoom
3. Durante drag, chama `parent.move_card(ref.node)` via duck-typing

### Duck-typing para game objects

O core NÃO pode saber sobre classes do jogo (`PlayerHand`, `Card`). Usamos duck-typing:

```gdscript
# interaction_system.gd (core)
var parent = ref.node.get_parent()
if parent and parent.has_method("move_card"):
	parent.move_card(ref.node)

func _check_drop(card: Node) -> DropZone:
	# usa card: Node, não card: Card
```

### Guardas de segurança

- Sempre verificar `world.has_component(entity_id, Componente)` antes de `world.get_component()`
- `_apply_visual` em `card.gd` usa `guard` para verificar se storage existe

---

## Turnos (TurnMachine)

### `scripts/core/turn/turn_machine.gd`

Engine genérica de turnos:

- `locks[entity_id] = bool` — controle de interação
- `hand_hooks[entity_id] = Vector2` — posição de animação da mão
- Fases de turno gerenciadas por estados

### `scripts/game/systems/turn_sequence_system.gd`

Extensão para UNO com sequência específica: comprar, jogar, descartar, etc.

---

## Validação (ValidationSystem)

### `scripts/core/validation/validation_system.gd`

Sistema de validação baseado em **rules** (regras). Não usa validação inline nos sistemas.

Cada rule implementa:

```gdscript
class_name BaseRule extends RefCounted

func get_id() -> String:
	return "rule_id"

func validate(entity_id: int, target_zone: DropZone, context: Dictionary) -> bool:
	return true  # true = jogada válida
```

O `context` dicionário é populado pelo `ValidationSystem` com:
- `card_data: CardData` — dados da carta sendo jogada
- `target_zone: DropZone` — zona de destino
- `validation_system: ValidationSystem` — referência para consultar outras regras
- `uno_card: UnoCardComponent` (game) — componente UNO da carta sendo jogada
- `top_uno_card: UnoCardComponent` (game) — componente UNO da carta no topo

### Rule Pack

```gdscript
var rule_pack = RulePack.new()
rule_pack.rules = [
	preload("res://scripts/game/rules/basic_match_rule.gd").new(),
	preload("res://scripts/game/rules/skip_rule.gd").new(),
]
```

---

## Escolhas (PlayerChoiceSystem)

### `scripts/core/choice/player_choice_system.gd`

Sistema genérico para solicitar escolhas dos jogadores:

- `request_choice(player_id, type, data)` — servidor solicita escolha
- `choice_received` — emitido quando jogador responde (ou timeout)
- `choice_ui_requested` — emitido para que o jogo abra a UI apropriada

### Conexão com UI do jogo

```gdscript
# game.gd
func _connect_choice_ui() -> void:
	var choice_sys = $WorldRunner/PlayerChoiceSystem
	if choice_sys:
		choice_sys.choice_ui_requested.connect(
			func(request_id: String, type: String, data: Dictionary):
				ChoiceUI.open(request_id, type, data, $front)
		)
```

Tipos de escolha implementados:
- `"color"` — escolher cor do coringa
- `"target_player"` — escolher jogador alvo
- Outros — confirmação simples

---

## Como Criar um Novo Jogo de Carta

### 1. Definir Componentes do Jogo

Crie `scripts/game/components/seu_jogo_component.gd`:

```gdscript
class_name MeuJogoCardComponent extends Component
@export var suit: int
@export var rank: int
```

### 2. Definir CardData

```gdscript
class_name MeuJogoCardData extends CardData
@export var suit: int
@export var rank: int
```

### 3. Criar Visual da Carta

```gdscript
# scripts/game/card/card.gd (ou similar)
func _apply_visual(entity_id: int) -> void:
	if not world.has_component(entity_id, MeuJogoCardComponent):
		return
	var comp = world.get_component(entity_id, MeuJogoCardComponent)
	# atualiza visual com comp.suit, comp.rank
```

### 4. Criar Regras de Validação

```gdscript
class_name MinhaRule extends BaseRule
func get_id() -> String: return "minha_rule"
func validate(entity_id: int, target_zone: DropZone, context: Dictionary) -> bool:
	var card = context.get("meu_jogo_card")
	return card.suit == 0  # exemplo
```

### 5. Conectar no Scene

Adicione seus sistemas como children de `WorldRunner` no `game.tscn`.

---

## Gotchas & Pitfalls

1. **`world.get_component` crasha se storage não existe**: sempre usar `world.has_component` como guarda
2. **Herança de Component não funciona**: usar composição (múltiplos componentes na mesma entidade)
3. **Batches de replicator são separados por tipo**: `UnoCardComponent` e `CardComponent` chegam em batches diferentes
4. **Locks stale**: só são atualizados quando batch contém `TurnComponent` — cartas jogadas podem ficar com locks obsoletos até próximo batch de turno
5. **`Container._sort_children()`** interfere com `global_position = pos_snap` — workaround com no-op em `static_vbox.gd`
6. **GDScript não permite** atribuir valor de tipo classe pai a variável de tipo classe filha — usar `as Cast` seguro
7. **`Replicator.push_state` quando `connected_count <= 1`**: chama `_apply_batch` síncrono (single-player)
8. **`SyncBarrier._process()`**: tem guarda de peer ativo — não crasha ao desconectar
9. **`_return_to_lobby`**: aceita argumento opcional (`_unused: int = 0`)
10. **`ChoiceUI.open()`**: agora é invocado via signal `choice_ui_requested`, nunca diretamente do core

---

## Eventos do Sistema

| Evento | Emissor | Propósito |
|--------|---------|-----------|
| `on_card_input(entity_id, event)` | Card visual → `world.events` | Input de carta |
| `on_card_dropped(entity_id, dropzone)` | InteractionSystem → `world.events` | Carta solta em zona |
| `on_game_entity_ready(entity_id)` | GameSetupSystem → `world.events` | Entidade do jogo criada |
| `choice_ui_requested(request_id, type, data)` | PlayerChoiceSystem | Abrir UI de escolha |
| `batch_applied(entries)` | Replicator | Batch de replicação aplicado |
