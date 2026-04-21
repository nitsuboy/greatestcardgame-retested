class_name Dealer
extends Node

@export var deck: CardDeck
@export var cardtemplate: PackedScene
var component_registry: Dictionary = {}


func _init() -> void:
	for c: Script in load_component_scripts("res://scripts/"):
		component_registry[c.get_global_name()] = c


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
		card_dict["entity_id"] = Entity.calculate_next_id()
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
		var comp_type = comp.get("type", "")
		var comp_class = component_registry.get(comp_type)

		if comp_class:
			var new_comp = comp_class.new()
			new_comp.from_dict(comp.get("data", {}))
			card_data.components.append(new_comp)
	var card: Card = cardtemplate.instantiate()
	card.card_data = card_data
	card.post_instantiate(card_dict["entity_id"])
	return card


func load_component_scripts(path: String) -> Array:
	var dir = DirAccess.open(path)
	var result = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if not file_name.begins_with("."):
					result += load_component_scripts(path + "/" + file_name)
			else:
				if file_name.ends_with("_component.gd"):
					var script = load(path + "/" + file_name)
					if script:
						result.append(script)
			file_name = dir.get_next()
		dir.list_dir_end()
	return result


func discard_card(card: Card) -> void:
	deck.discard(card.card_data)
	card.queue_free()
