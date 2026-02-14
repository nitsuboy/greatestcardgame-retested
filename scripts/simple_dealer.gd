class_name SimpleDealer
extends Node

@export var deck: CardDeck
@export var cardtemplate: PackedScene


func _ready() -> void:
	load_decks()


func load_decks() -> void:
	deck.load_cards()
	deck.shuffle()


func draw_card(id: int = -1, entity_id = -1) -> Card:
	var card_data: CardData
	var card: Card = cardtemplate.instantiate()
	if id == -1:
		card_data = deck.draw()
		if card_data:
			card.card_data = card_data
			return card
		push_warning("no more cards, deck")
		return null
	card_data = deck.cards_data[id]
	card.card_data = card_data
	card.entity.id = entity_id
	card.entity.all_entities[entity_id] = card.entity
	return card


func discard_card(card: Card) -> void:
	deck.discard(card.card_data)
	var effect = EntitySystem.get_comp(card.entity, EffectComponent)
	if effect:
		EffectSystem.unapply(effect, card)
	card.queue_free()
