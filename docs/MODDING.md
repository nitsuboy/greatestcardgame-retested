# Guia de Modding - greatestcardgame-retested

Este documento descreve os fluxos do jogo e os pontos de modificação para customizar o comportamento do jogo.

---

## Nova Estrutura de Pastas

```
scripts/
├── core/              # OOP - Lógica Principal do Jogo
│   ├── game_manager.gd
│   ├── simple_game_manager.gd
│   ├── network_manager.gd
│   ├── globals.gd
│   ├── lobby.gd
│   ├── main_menu.gd
│   ├── player.gd
│   ├── player_hand.gd
│   ├── dealer.gd
│   ├── drop_zone.gd
│   ├── card/
│   │   ├── card.gd
│   │   ├── card_data.gd
│   │   └── card_deck.gd
│   └── rules/
│       ├── rules.gd
│       └── game_rules.gd
├── ecs/              # Framework ECS
│   ├── components/
│   ├── systems/
│   ├── component.gd
│   ├── entity.gd
│   ├── event.gd
│   └── system.gd
├── game/             # Sistemas de Jogo (ECS-like)
│   ├── play_cards/
│   ├── draw_cards/
│   ├── discard_cards/
│   ├── dragging/
│   ├── hover/
│   ├── input/
│   ├── trigger/
│   ├── turn/
│   └── zoom/
├── ui/              # Componentes de UI
└── utils/           # Utilitários
```

---

## Fluxo de Jogo

### 1. Início de Partida
```
MainMenu → Lobby → [Host/Join] → Game (Cards dealt)
```

1. **MainMenu** (`core/main_menu.gd`): Menu principal com opções
2. **Lobby** (`core/lobby.gd`): Menu multiplayer para criar/entrarr em servidores
3. **NetworkManager** (`core/network_manager.gd`): Gerencia conexões (WebSocket + UDP discovery)
4. **Game Start**: Dealer distribui cartas para os jogadores

### 2. Turno de Jogo
```
Start Turn → Player Action → Execute Triggers → End Turn → Next Player
```

1. **TurnSystem** (`game/turn/systems/turn_system.gd`): Controla mudança de turno
2. **Player Action**: Jogador pode Jogar Cartas, Comprar, Descartar
3. **Trigger Execution**: Triggers são resolvidos após ação
4. **End Turn**: Passa turno para próximo jogador

### 3. Jogar Carta
```
Drag Card → Drop on Zone → Rules Validation → PlayCardSystem → Trigger Resolution
```

1. **DraggableComponent** (`game/dragging/components/draggable_component.gd`): Permite arrastar
2. **DropZone** (`core/drop_zone.gd`): Zona que recebe cartas
3. **GameRules** (`core/rules/game_rules.gd`): Valida se carta pode ser jogada
4. **PlayCardSystem** (`game/play_cards/systems/play_card_system.gd`): Resolve jogada
5. **TriggerSystem** (`game/trigger/systems/trigger_system.gd`): Dispara triggers da carta

---

## Sistema de Ações

`GameManager.Actions` enum define todas as ações possíveis:

| Ação | Descrição |
|------|-----------|
| `PLAY_CARD` | Jogar uma carta no tabuleiro |
| `END_TURN` | Encerrar turno |
| `DRAW_CARD` | Comprar cartas do deck |
| `DISCARD_CARD` | Descartar carta |
| `MODIFY_CARD` | Modificar atributos |
| `CREATE_CARD` | Criar nova carta |
| `SKIP_TURN` | Pular turno |

Local: `scripts/core/game_manager.gd:2`

---

## Sistema de Triggers

### Componentes de Trigger

**TriggerOnComponent** (`trigger/trigger_on_component.gd`):
- `key_out`: Identificador do trigger
- Dispara trigger quando a carta é jogada

**OnTriggerComponent** (`trigger/on_trigger_component.gd`):
- `keys_in`: Lista de chaves que escuta
- Executa ação quando trigger correspondente é disparado

### Triggers Disponíveis

| Componente | Efeito |
|-------------|--------|
| `DrawOnTriggerComponent` | Compra cartas |
| `SkipTurnOnTriggerComponent` | Pula turnos |
| `DiscardOnTriggerComponent` | Descarta carta |
| `LogOnTriggerComponent` | Log de debug |

### Criando Novo Trigger

1. **Criar componente que escuta** em `game/trigger/components/`:
```gdscript
class_name MyOnTriggerComponent
extends OnTriggerComponent

var my_value: int

func _init() -> void:
    keys_in = ["my_trigger_key"]
```

2. **Adicionar handling** em `game/trigger/systems/trigger_system.gd`:
```gdscript
match on_trigger_comp.get_script():
    MyOnTriggerComponent:
        var comp = on_trigger_comp as MyOnTriggerComponent
        # executar ação
```

3. **Adicionar componente** na carta via editor ou código

---

## Sistema de Cartas

### CardData (Dados)
`scripts/core/card/card_data.gd`: Resource com dados da carta

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `card_name` | String | Nome da carta |
| `card_value` | CardValue | Valor (0-13) |
| `card_color` | CardColor | Cor (0-4) |
| `components` | Array[Component] | Componentes |
| `id` | int | ID único |

### Card (Visual)
`scripts/core/card/card.gd`: Control node que exibe a carta

- Separação clara: CardData = dados, Card = visual
- Animações de movimento, rotação, escala
- Suporte a hover (Highlight) e zoom

### CardDeck
`scripts/core/card/card_deck.gd`: Array de CardData

### CardDeckGenerator
`scripts/utils/card_deck_generator.gd`: Gera decks aleatórios

---

## Pontos de Modificação

### 1. Adicionar Nova Carta

1. Criar `CardData` em `resources/data_cards/`
2. Definir nome, descrição, arte, custo
3. Adicionar componentes de comportamento
4. Adicionar ao deck em `resources/card_decks/`

### 2. Adicionar Novo Efeito/Componente

1. Criar componente em `scripts/game/<modulo>/components/`
2. Implementar lógica em sistema correspondente
3. Adicionar ao CardData desejado

### 3. Modificar Regras de Jogo

| Arquivo | O que Alterar |
|---------|---------------|
| `core/game_manager.gd` | Ações disponíveis |
| `core/rules/game_rules.gd` | Validação de jogada |
| `core/rules/rules.gd` | Abstract de regras |
| `game/turn/systems/turn_system.gd` | Lógica de turno |
| `game/draw_cards/systems/draw_card_system.gd` | Quantidade de compras |
| `game/discard_cards/systems/discard_card_system.gd` | Lógica de descarte |
| `game/play_cards/systems/play_card_system.gd` | Validação de jogada |

### 4. Modificar Multiplayer

| Arquivo | O que Alterar |
|---------|---------------|
| `core/network_manager.gd` | Portas, timeouts, protocolo |
| `core/lobby.gd` | UI de lobby, configurações |

### 5. Modificar UI

| Cena | Descrição |
|------|-----------|
| `scenes/Card.tscn` | Aparência da carta |
| `scenes/DropZone.tscn` | Zona de drop |
| `scenes/Main.tscn` | Cena principal |
| `scenes/Lobby.tscn` | Menu multiplayer |

---

## Estrutura de Arquivos

```
res::/
├── docs/           # Documentação
├── resources/      # CardData, CardDecks, Effects
├── scenes/        # Cenas Godot
├── assets/        # Texturas, shaders
└── scripts/       # Código GDScript
    ├── core/      # OOP - Lógica Principal
    ├── ecs/      # Framework ECS
    ├── game/     # Sistemas de Jogo
    ├── ui/       # Componentes de UI
    └── utils/    # Utilitários
```

---

## Como Debugar

1. **Debug Visual**: Ativar `Globals.debug = true` em `scripts/core/globals.gd`
2. **Logs de Trigger**: Ver saída console com prefixo `=== TriggerSystem:`
3. **Network Debug**: Ver logs de sync em `core/network_manager.gd`
4. **Card Debug**: Ver `hand` e `deck` dos jogadores
5. **Rules Debug**: Ver logs de validação em `core/rules/game_rules.gd`

---

## Sistema de Regras

### Abstract: `rules.gd`

```gdscript
class_name Rules
extends Node

@abstract func can_play(context: Dictionary) -> bool
```

### Implementação: `game_rules.gd`

```gdscript
class_name GameRules
extends Rules

var last_card: Array[int] = [-1, -1]  # [color, value]

func can_play(context: Dictionary) -> bool:
    # Lógica de validação específica do jogo
    ...
```

### Context de Validação

```gdscript
var context = {
    "card": entity_id,      # ID da entidade da carta
    "dropzone": entity_id   # ID da zona de drop
}
```