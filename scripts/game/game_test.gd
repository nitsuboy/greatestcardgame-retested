extends Node2D

@onready var draw_btn: Button = $CanvasLayer/Button2
@onready var status: RichTextLabel = $CanvasLayer/RichTextLabel


func _ready() -> void:
	Players.add_player(1, {"name": "Debug", "state": 0})
	await get_tree().process_frame
	_start_game()

	draw_btn.pressed.connect(_on_draw_pressed)

	$WorldRunner.world.events.on_card_dropped.connect(_on_card_dropped)
	$WorldRunner.world.events.on_card_played.connect(_on_card_played)


func world() -> World:
	return $WorldRunner.world


func _start_game() -> void:
	var w = world()
	var dealer = $WorldRunner/DealerSystem
	var rep = $WorldRunner/Replicator

	dealer.deck.load_cards()
	dealer.deck.shuffle()

	var batch: Array[Dictionary] = []

	var turn_entity = w.create_entity()
	var turn_comp = TurnComponent.new()
	w.add_component(turn_entity, turn_comp)
	batch.append(
		{"entity": turn_entity, "type": TurnComponent.resource_path, "data": turn_comp.to_dict()}
	)

	var player_entity = w.create_entity()
	var player_comp = PlayerComponent.new()
	player_comp.peer_id = 1
	player_comp.hand_zone_id = 1
	w.add_component(player_entity, player_comp)
	batch.append(
		{
			"entity": player_entity,
			"type": PlayerComponent.resource_path,
			"data": player_comp.to_dict()
		}
	)

	for i in range(7):
		var e = dealer._create_card_entity(1)
		if e < 0:
			break
		batch.append(
			{
				"entity": e,
				"type": CardComponent.resource_path,
				"data": w.get_component(e, CardComponent).to_dict()
			}
		)

	rep.push_state(batch, "setup_0")
	status.text = "Jogo iniciado — %d cartas" % 7


func _on_draw_pressed() -> void:
	Remote.send("draw_card", {"amount": 1, "player": 1})
	status.text = "Draw card enviado"


func _on_card_dropped(entity: int, zone) -> void:
	status.text = "Carta %d dropada em %s" % [entity, zone.name]


func _on_card_played(entity: int, played_by: int) -> void:
	status.text = "Carta %d jogada por %d" % [entity, played_by]
