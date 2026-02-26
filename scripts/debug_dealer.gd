class_name DebugDealer
extends Node

@export var deck: CardDeck
@export var cardtemplate: PackedScene


func _ready() -> void:
	load_decks()


func load_decks() -> void:
	deck.load_cards()
	deck.shuffle()


func draw_card(id: int = -1, entity_id: int = -1) -> Card:
	var card_data: CardData
	var card: Card = cardtemplate.instantiate()
	if id == -1:
		card_data = deck.draw()
	else:
		card_data = deck.draw(id)
	if card_data:
		card.card_data = card_data
		card.post_instantiate(entity_id)
		return card
	push_warning("no more cards, deck")
	return null


func discard_card(card: Card) -> void:
	if multiplayer.is_server():
		deck.discard(card.card_data)
	var node_comp = EntitySystem.get_comp(card.entity, NodeComponent)
	if node_comp:
		node_comp.node.queue_free()
	Entity.all_entities.erase(card.entity.id)
