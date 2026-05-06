@abstract class_name GameManager
extends Node

enum GameState { SETUP, TURN_START, PROCESS_TURN, END_GAME }

enum Actions {
	PLAY_CARD,
	END_TURN,
	DRAW_CARD,
	DRAW_CARD_UNSK,
	DISCARD_CARD,
	MODIFY_CARD,
	CREATE_CARD,
	SKIP_TURN,
	START_TURN,
	SPAWN_PROTOTYPE,
	CHANGE_COLOR
}

var _players_entities: Dictionary[int, Entity] = {}
var _state_track: int = 0

@abstract func get_dealer() -> Dealer
