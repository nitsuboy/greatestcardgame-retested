class_name UmRules
extends Rules

var last_card: Array[int] = [-1, -1]
var stack: int = 0


func validate(context: ValidationContext) -> ValidationResult:
	match context.action:
		GameManager.Actions.PLAY_CARD:
			return _validate_play_action(context)
		GameManager.Actions.DRAW_CARD:
			return _validate_draw_action(context)
		GameManager.Actions.START_TURN:
			return _validate_start_turn_action(context)
		_:
			return valid()


func _validate_start_turn_action(ctx: ValidationContext):
	var player_id = ctx.player_id
	var hand = _get_player_hand(player_id)
	var game = Net.game
	# Verifica se tem carta jogável
	var has: bool = _has_playable_card(hand)
	if has:
		return valid()
	var num_cards = 0
	var result = invalid("")
	for i in range(10):
		var card_data = game.peek_card(num_cards)
		print(card_data)
		num_cards += 1
		if _validate_color(card_data) or result.is_valid:
			result.is_valid = true
			break
		if _validate_value(card_data) or result.is_valid:
			result.is_valid = true
			break
	result.data["num_cards"] = num_cards
	return result


# ============================================
# PLAY_CARD
# ============================================


func _validate_play_action(ctx: ValidationContext) -> ValidationResult:
	var card_entity = EntityRegistry.get_entity(ctx.args[0])
	var card_data = _get_card_data(card_entity)
	# 1. Validação básica: cor, valor, WILD

	var result = invalid("cor e numero incompativel")

	if _validate_color(card_data) or result.is_valid:
		result = valid()

	if _validate_value(card_data) or result.is_valid:
		result = valid()

	if result.is_valid:
		last_card[0] = card_data.card_color
		last_card[1] = card_data.card_value

	return result


func _validate_color(card_data: CardData) -> bool:
	if last_card[0] == -1:
		return true

	if card_data.card_color == Card.CardColor.WILD:
		return true

	return card_data.card_color == last_card[0]


func _validate_value(card_data: CardData) -> bool:
	if last_card[1] == -1:
		return true

	# Mesmo valor funciona
	if card_data.card_value == last_card[1]:
		return true

	return false


# ============================================
# DRAW_CARD
# ============================================


func _validate_draw_action(ctx: ValidationContext) -> ValidationResult:
	var player_id = ctx.target_id
	var hand = _get_player_hand(player_id)

	if _has_response_card(hand):
		stack += ctx.args[0]
		$"../Background/RichTextLabel".text = str(stack)
		return invalid("hehe o proximo ta fudido")
	ctx.args[0] += stack
	stack = 0
	Net.modify_front_trigger_action(ctx.args)
	return valid()


func _has_playable_card(hand: Node) -> bool:
	if hand.get_child_count() == 0:
		return false

	for i in range(hand.get_child_count()):
		print("checou carta %d" % i)
		var card = hand.get_card(i)
		if card == null or card.card_data == null:
			continue
		var card_data = card.card_data
		if _validate_color(card_data):
			return true
		if _validate_value(card_data):
			return true

	return false


func _has_response_card(hand: Node) -> bool:
	if hand.get_child_count() == 0:
		return false

	for i in range(hand.get_child_count()):
		var card = hand.get_card(i)
		if EntitySystem.has_comp(card.entity, DrawOnTriggerComponent):
			return true

	return false


# ============================================
# WILD COLOR CHOICE
# ============================================


func _validate_wild_choice(ctx: ValidationContext) -> ValidationResult:
	var color = ctx.args[0]  # Card.CardColor escolhido

	if color == Card.CardColor.WILD:
		return invalid("Não pode escolher WILD como cor")

	if color < 0 or color > 3:  # só 0-3 são cores válidas
		return invalid("Cor inválida")

	return valid()


# ============================================
# HELPER FUNCTIONS
# ============================================


func _get_card_data(card_entity: Entity) -> CardData:
	var node_comp = EntitySystem.get_comp(card_entity, NodeComponent)
	return node_comp.node.card_data


func _get_player_hand(player_id: int) -> Node:
	var game = Net.game
	return game.get_player_hand(player_id)


func invalid(msg: String) -> ValidationResult:
	var result = ValidationResult.new()
	result.is_valid = false
	result.rejected_reason = msg
	return result


func valid() -> ValidationResult:
	var result = ValidationResult.new()
	result.is_valid = true
	return result
