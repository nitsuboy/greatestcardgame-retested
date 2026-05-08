class_name EntityDeleteEvent
extends Event

var entity: Entity
# Isso parece redundante,
# mas é pq esse evento tbm é chamado no global (já que a entidade ta sendo deletada)


func _init(_entity: Entity) -> void:
	entity = _entity
