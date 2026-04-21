class_name DiscardCardSystem
extends System


static func discard_card(entity: Entity, _comp: NodeComponent) -> void:
	var dealer = NetworkManager.game._dealer
	dealer.discard_card(_comp.node)

	if NetworkManager.multiplayer.is_server():
		var e_args = DiscardCardEventArgs.new(entity)
		var e = DiscardCardEvent.new(e_args)
		e.start()
