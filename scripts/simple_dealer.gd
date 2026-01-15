class_name SimpleDealer
extends Node

const CARD_TYPE = preload("res://scripts/cards/Enums.gd").CardType

@export var deck: CardDeck
@export var cardtemplate: PackedScene


func _ready() -> void:
	load_decks()


func load_decks() -> void:
	deck.load_cards()
	deck.shuffle()


func draw_card() -> Card:
	var card_data: CardData
	var card: Card = cardtemplate.instantiate()
	card_data = deck.draw()
	if card_data:
		card.card_data = card_data
		return card
	push_warning("no more cards, deck")
	return null


func discard_card(card: Card) -> void:
	deck.discard(card.card_data)
	var effect = EntitySystem.get_comp(card.entity, EffectComponent)
	if effect:
		EffectSystem.unapply(effect, card)
	card.queue_free()
