# ecs/event_bus.gd
class_name EventBus
extends RefCounted

signal on_entity_created(entity: int)
signal on_entity_destroyed(entity: int)
signal on_component_added(entity: int, component_type: Script)
signal on_component_removed(entity: int, component_type: Script)
