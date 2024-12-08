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
				- pontuar 1
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
![[mainmenu 1.png]]
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

#### ícones

| id  | imagem                  |
| --- | ----------------------- |
| 100 | Teste de aceitação      |
| 101 | Teste de desempenho     |
| 102 | Teste de estresse       |
| 103 | Teste de funcionalidade |
| 104 | Teste de segurança      |
| 105 | Teste de usabilidade    |
| 200 | contratação forçada     |
| 201 | Contrato temporário     |
| 202 | espião                  |
| 203 | ferramenta              |
| 204 | proposta internacional  |
| 205 | sabotagem               |
| 206 | testador                |
| 207 | trabalho corporativo    |
|     | especialista            |
|     | estagiário              |
|     | hora extra              |
|     | reunião                 |

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
>func DoSomething(param:int) -> void:
>	pass
>```