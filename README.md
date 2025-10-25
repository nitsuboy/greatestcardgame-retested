# 🎴 Card Framework (Godot 4)

![Godot](https://img.shields.io/badge/engine-Godot%204-blue?logo=godot-engine&logoColor=white)
![Language](https://img.shields.io/badge/language-GDScript-orange)
![Status](https://img.shields.io/badge/status-in%20development-yellow)

Um **framework básico para jogos de cartas** desenvolvido em **Godot 4**, projetado para servir como base na criação de jogos de cartas colecionáveis, tabuleiros ou sistemas interativos que utilizam cartas arrastáveis, efeitos modulares e zonas de drop.

---

## 🚀 Funcionalidades
- 🖱️ **Arrastar e soltar** cartas no tabuleiro.  
- ✨ **Animações suaves** de movimento, rotação e escala.  
- 👆 **Sistema de foco/hover** para destacar cartas.  
- 🎯 **DropZones** que recebem cartas e executam efeitos.  
- 🔗 **Efeitos modulares** aplicados a qualquer tipo de carta.  
- 🗂️ **Separação entre dados e visual**: `data_card` → `card`.  

---

## 📦 Recursos
- **`data_card`** → Dados da carta (nome, descrição, arte, efeitos).  
- **`card_deck`** → Conjunto de `data_cards` que formam o deck.  
- **`effect`** → Efeito modular de uma carta, responsável por generalizar a ação que ela executa.  

---

## 🧩 Nós Principais
- **`card`** → Modelo visual e interativo da carta.  
- **`dealer`** → Constrói cartas interativas a partir de `data_cards` do deck.  
- **`player`** → Armazena informações e estado dos jogadores.  
- **`dropzone`** → Área de interação onde cartas podem ser soltas para gerar efeitos.  

---

## 📂 Estrutura do Projeto
```
res://
├── docs/         # Documentos do projeto (GIT.md, INFO PROJECT.md)
├── resources/    # Dados do jogo (data_cards, card_decks, efeitos)
├── scenes/       # Cenas principais (Card.tscn, DropZone.tscn, Main.tscn)
├── scripts/      # Lógica do jogo em GDScript
└── tex/          # Texturas e artes (imagens das cartas, UI, etc.)
```