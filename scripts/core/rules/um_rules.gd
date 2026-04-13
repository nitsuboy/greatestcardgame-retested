class_name UmRules
extends Rules

var last_card: Array[int] = [-1, -1]


func can_play(context: Dictionary) -> bool:
	print("  lcc: %d | lcv: %d" % last_card)
	var card_ent = Entity.all_entities[context.get("card")]
	if not card_ent:
		return false
	var node_comp = EntitySystem.get_comp(card_ent, NodeComponent)
	if not node_comp:
		return false

	var card_data: CardData = node_comp.node.card_data

	var card_color = card_data.card_color
	var card_value = card_data.card_value
	var last_color = last_card[0]
	var last_value = last_card[1]

	var play: bool = false

	play = (
		card_color == last_color or card_value == last_value or card_color == Card.CardColor.WILD
	)

	if last_card[0] == -1 and last_card[1] == -1:
		play = true

	if play:
		last_card[0] = card_color
		last_card[1] = card_value

	return play
