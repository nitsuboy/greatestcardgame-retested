## carta faz com que um jogador compre cartas ao receber um trigger
class_name DrawOnTriggerComponent
extends OnTriggerComponent

## quantas cartas comprar
@export var number_of_cards: int = 1

## qual jogador compra as cartas
@export var player: int = 0
