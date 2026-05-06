class_name Dealer
extends Node

@export var deck: CardDeck
@export var cardtemplate: PackedScene


func _ready() -> void:
	load_decks()


func load_decks() -> void:
	deck.load_cards()
	deck.shuffle()


func peek_deck(amount: int = 0) -> CardData:
	return deck.peek(amount)


func draw_card(card_id: int = -1, entity_id: int = -1) -> Card:
	var card_data: CardData
	var card: Card = cardtemplate.instantiate()
	card_data = deck.draw(card_id)
	if card_data:
		card.card_data = card_data
		card.post_instantiate(entity_id)
		return card
	push_warning("no more cards, deck")
	return null


func draw_card_dict(card_id: int = -1) -> Dictionary:
	var card_data: CardData
	card_data = deck.draw(card_id)
	if card_data:
		var card_dict = card_data.to_dict()
		card_dict["entity_id"] = EntityRegistry.calculate_next_entity_uid()
		return card_dict
	push_warning("no more cards, deck")
	return {}


func make_card_from_dict(card_dict: Dictionary) -> Card:
	var card_data: CardData = CardData.new()
	card_data.id = card_dict["id"]
	card_data.card_color = card_dict["color"]
	card_data.card_name = card_dict["name"]
	card_data.card_value = card_dict["value"]
	for comp in card_dict.get("components", []):
		var comp_class = ComponentRegistry.get_component_type(comp.get("type", ""))
		if comp_class:
			var new_comp = comp_class.new()
			EntitySystem.from_dict_to_component(new_comp, comp.get("data", {}))
			card_data.components.append(new_comp)
	var card: Card = cardtemplate.instantiate()
	card.card_data = card_data
	card.post_instantiate(card_dict["entity_id"])
	return card


func discard_card(card: Card) -> void:
	deck.discard(card.card_data)
	card.queue_free()
