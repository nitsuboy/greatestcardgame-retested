class_name HandsController
extends RefCounted


func apply_turn_state(
	active_player_id: int,
	players_entities: Dictionary,
	local_player_id: int,
	all_player_ids: Array[int]
) -> void:
	for id in all_player_ids:
		var player_comp = EntitySystem.get_comp(players_entities[id], PlayerComponent)
		if not player_comp:
			continue
		if id == active_player_id:
			if id == local_player_id:
				player_comp.hand.unblock_hand()
			player_comp.hand.raise_hand()
		else:
			if id == local_player_id:
				player_comp.hand.block_hand(true, false)
			else:
				player_comp.hand.block_hand(true, true)
			player_comp.hand.lower_hand()
