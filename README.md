# Card Framework (Godot 4)

![Godot](https://img.shields.io/badge/engine-Godot%204-blue?logo=godot-engine&logoColor=white)
![Language](https://img.shields.io/badge/language-GDScript-orange)
![Status](https://img.shields.io/badge/status-in%20development-yellow)
![Version](https://img.shields.io/badge/version-v0.8.0-green)
![Architecture](https://img.shields.io/badge/architecture-ECS%2BOOP-purple)

Framework de jogo de cartas multiplayer em Godot 4 com arquitetura híbrida ECS + OOP.

---

## Arquitetura

### Estrutura de Pastas

```
scripts/
├── core/           # OOP - Lógica Principal do Jogo
├── ecs/           # Framework ECS (Entity-Component-System)
├── game/          # Sistemas de Jogo (ECS-like)
├── ui/            # Componentes de UI
└── utils/        # Utilitários
```

### Hierarquia de Classes

```
core/
├── game_manager.gd          # Enum Actions (base)
├── simple_game_manager.gd   # Game Manager principal
├── network_manager.gd       # Rede multiplayer
├── player.gd               # Jogador
├── player_hand.gd            # Mão do jogador
├── dealer.gd               # Distribuidor de cartas
├── globals.gd              # Variáveis globais
├── lobby.gd               # Menu multiplayer
├── main_menu.gd            # Menu principal
├── drop_zone.gd           # Zona de drop
├── card/
│   ├── card.gd           # Visual da carta
│   ├── card_data.gd        # Dados da carta
│   └── card_deck.gd       # Deck de cartas
└── rules/
    ├── rules.gd            # Abstract base
    └── game_rules.gd      # Regras do jogo (implementação)
```

---

## Sistema de Regras

### Abstract: `rules.gd`

Classe base abstrata para validação de jogadas:

```gdscript
class_name Rules
extends Node

@abstract func can_play(context: Dictionary) -> bool
```

### Implementação: `game_rules.gd`

Implementação específica do jogo que estende `Rules`:

```gdscript
class_name GameRules
extends Rules

var last_card: Array[int] = [-1, -1]  # [color, value]

func can_play(context: Dictionary) -> bool:
    # Lógica de validação específica do jogo
    ...
```

### Integração

O `SimpleGameManager` integra com o sistema de regras:

```gdscript
@export var _rules: Rules

func do_action(...) -> void:
    match _action:
        Actions.PLAY_CARD:
            var context = {"card": _args[0], "dropzone": _args[1]}
            if not _rules.can_play(context):
                print("  Refused")  # Jogada inválida
            else:
                _play_card_mult.rpc(...)
```

---

## Cartas

### Enum: `Card.CardColor`

| Valor | Cor |
|-------|-----|
| `YELLOW` | Amarelo |
| `RED` | Vermelho |
| `GREEN` | Verde |
| `BLUE` | Azul |
| `WILD` | Coringa |

### Enum: `Card.CardValue`

| Valor | Carta | Efeito |
|-------|-------|--------|
| `0-9` | Número | - |
| `10` | SKIP | Pula próximo jogador |
| `11` | REVERSE | Inverte direção |
| `12` | +2 | Próximo compra 2 |
| `13` | +4 | Próximo compra 4 + escolhe cor |

---

## Multiplayer

### Protocolo

- **WebSocket** (porta 7357): Comunicação principal
- **UDP** (portas 63574-63575): Discovery de servidores LAN

### Sistema de Sync

- Timeouts com retries para sincronização
- Confirmação de estado entre clientes

---

## Hotspots

| Arquivo | Função | Modificar Para |
|--------|-------|--------------|
| `core/rules/game_rules.gd` | Regras do jogo | Novas regras |
| `core/simple_game_manager.gd` | Game Manager | Fluxo de jogo |
| `core/network_manager.gd` | Rede | Portas, protocolos |
| `core/card/card.gd` | Visual da carta | Aparência |
| `game/play_cards/systems/play_card_system.gd` | Jogar carta | Validação |

---

## Quick Links

- [Guia de Modding](docs/MODDING.md)
- [ECS Design](docs/ECS.md)

---

## Requisitos

- Godot 4.x
- GDScript

---

## Status

v0.8.0 - Em desenvolvimento