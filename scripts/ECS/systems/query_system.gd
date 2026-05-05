class_name QuerySystem
extends System

## Retorna um array com todas as entidades
static func all_entities() -> Array[Entity]:
	var aux: Array[Entity] = []

	for entity_uid in EntityRegistry.get_current_entities().keys():
		var entity = EntityRegistry.get_entity(entity_uid)
		if not entity:
			push_error("Entidade (uid: %d) deletada dentro de _current_entities" % entity_uid)
			return []
		aux.append(entity)

	return aux


## Retorna todas as entidades que tem determinado componente
static func all_entities_with_comp(comp_type: Script) -> Array[Entity]:
	var aux: Array[Entity] = []

	for entity_uid in ComponentRegistry.get_component_registry().get(comp_type).keys():
		var entity = EntityRegistry.get_entity(entity_uid)
		if not entity:
			push_error("Entidade (uid: %d) deletada dentro de _all_components" % entity_uid)
			return []
		aux.append(entity)

	return aux


## Retorna todas as entidades que tem dois determinados componentes
static func all_entities_with_comp2(comp_type1: Script, comp_type2: Script) -> Array[Entity]:
	var aux: Array[Entity] = []

	# TODO: fazer isso né

	return aux
