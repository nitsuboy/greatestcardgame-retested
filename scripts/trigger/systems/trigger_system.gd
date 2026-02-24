class_name TriggerSystem
extends System

enum Action { PLAYED }
static var _on_trigger_components: Array[Script] = [DrawOnTriggerComponent]


static func try_trigger(entity: Entity, trigger_id: int) -> void:
	var comps = EntitySystem.get_comps(entity, _on_trigger_components)
	for comp in comps:
		if comp.trigger_id == trigger_id:
			match comp.get_script():
				DrawOnTriggerComponent:
					if NetworkManager.multiplayer.is_server():
						NetworkManager.request_action(1, 2, comp.number_of_cards)
						return
					NetworkManager.request_action.rpc_id(1, 1, 2, comp.number_of_cards)
				_:
					push_warning("not in the action list")
