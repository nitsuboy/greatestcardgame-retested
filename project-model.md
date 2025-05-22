# Jogo
## Conceito
jogo de cartas multiplayer para o aprendizado interativo sobre teste de software
## Baralho atual

|   TIPO   |         NOME          | QUANT |
| :------: | :-------------------: | :---: |
| vermelha |       perguntas       |  37   |
|   azul   |     especialista      |   4   |
|   azul   | trabalho corporativo  |   4   |
|   azul   |       sabotagem       |   4   |
|   azul   |      estagiario       |   4   |
|   azul   |  contratação forçada  |   4   |
|   azul   |        espião         |   4   |
|   azul   | proposta intenacional |   4   |
|   azul   |      hora extra       |   4   |
|  verde   |       testador        |   8   |
|  verde   |      t,estresse       |   8   |
|  verde   |     t,usabilidade     |   8   |
|  verde   |     c,temporario      |   8   |
|  verde   |      ferramenta       |   8   |
|  verde   |        reunião        |   4   |
|  verde   |      t,segurança      |   8   |
|  verde   |     t,desempenho      |   8   |
|  verde   |   t,funcionalidade    |   8   |
|  verde   |      t,aceitação      |   8   |

|   tipo    | total |
| :-------: | :---: |
| vermelhas |  37   |
|   azuis   |  32   |
|  verdes   |  76   |
| **total** |  145  |

## Estrutura de turno
### Começo do jogo
- puxar X cartas
### Turnos restantes
- puxar uma carta
- usar cartas de efeito
- usar carta de testador
- jogar testes
	- acerto
		- puxar carta azul
		- rolar dado
			- acerto
				- pontuar Y
			- erro
				- encerra turno
	- erro
		- encerra turno
## Condição de vitória
- conseguir 5 pontos primeiro
# Indev
## Padronização
### Texturas
#### Main Menu
![palleta UI](images/0.png)
### Arquivos
- imagem
	- .png,.svg
	- snake_case
- áudio
	- .mp3
	- snake_case
- script
	- .gd
	- PascalCase
 - cena
	 - .tscn
	 - snake_case

#### ícones

| id  |         imagem          |                         |
| :-: | :---------------------: | ----------------------- |
| 100 |   Teste de aceitação    | ![[100.png\|100]]       |
| 101 |   Teste de desempenho   | ![[101.png\|100]]       |
| 102 |    Teste de estresse    | ![[102.png\|100]]       |
| 103 | Teste de funcionalidade | ![[103.png\|100]]       |
| 104 |   Teste de segurança    | ![[104.png\|100]]       |
| 105 |  Teste de usabilidade   | ![[105.png\|100]]       |
| 200 |   contratação forçada   | ![[200.png\|100]]       |
| 201 |   Contrato temporário   | ![[201.png\|100]]       |
| 202 |         espião          | ![[202.png\|100]]       |
| 203 |       ferramenta        | ![[203.png\|100]]       |
| 204 | proposta internacional  | ![[204.png\|100]]       |
| 205 |        sabotagem        | ![[205.png\|100]]       |
| 206 |        testador         | ![[206.png\|100]]       |
| 207 |  trabalho corporativo   | ![[207.png\|\|100]]     |
| 208 |      especialista       | ![[208.png\|100]]       |
| 209 |       estagiário        | ![[209.png\|100]]       |
| 210 |       hora extra        | ![[210.png\|100]]       |
| 211 |         reunião         | ![[211.png\|100]]       |
Créditos : <a href="https://www.flaticon.com/authors/dinosoftlabs" title="pagina do dinosoftlabs">ícones criados por DinosoftLabs - Flaticon</a>
### Padrão de código
- variaveis
	- snake_case
	- tipar variavel
	- deixar inicialização nula
- Sinais
	- PascalCase
- funções
	- PascalCase
	- sempre colocar retorno
	- tipar o parametro
- ordem
	- extends
	- class_name
	- signals
	- @export
	- @onready
	- var
	- enum
	- funcs
- comentado caso necessário 

>[!NOTE]- Exemplo
>```gdscript
>extends parent
>class_name class
>
>signal SendMessage(message)
>
>@export var name:string
>
>@onready var name_label:label = $label
>
>var count:int
>
>enum state {DOING,NOT_DOING}
>
>func DoSomething(param:int) -> void:
>	pass
>```

## Desenvolvimento
### UI jogo
![desing do tabuleiro](images/1.png)
![desing do tabuleiro](images/2.png)

### estrutura 
#### Jogo
- controladormultijogador:Node - goblal < - Nicolas
- Jogo:Node - scene
	- UI:Control
		- opcoes:{controles em geral}
	- partida:Partida <- Nikolas
		- crupie:Crupie
		- jogadores:Node2D
			- jogador_{id}:Jogador - scene
		- mesa:Mesa 
			- cartas_{tipo}:Node2D
				- posicao_{id}:Node2D
					- carta:Carta - scene
#### jogador
- jogador - scene
	- cartas
		- posicao_{id}:Node2D
	- pontos
	- botões
		- negociacao
		- terminar turno
