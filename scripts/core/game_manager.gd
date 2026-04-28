@abstract class_name GameManager
extends Node

enum Actions {
	PLAY_CARD,
	END_TURN,
	DRAW_CARD,
	DRAW_CARD_UNSK,
	DISCARD_CARD,
	MODIFY_CARD,
	CREATE_CARD,
	SKIP_TURN,
	START_TURN
}

@abstract func get_dealer() -> Dealer
