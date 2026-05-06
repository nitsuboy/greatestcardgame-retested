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
	var comp_dict = ComponentRegistry.get_component_registry().get(comp_type)

	for entity_uid in comp_dict.keys():
		var entity = EntityRegistry.get_entity(entity_uid)
		if not entity:
			push_error("Entidade (uid: %d) deletada dentro de _all_components" % entity_uid)
			return []
		aux.append(entity)

	return aux


## Retorna todas as entidades que tem dois determinados componentes
static func all_entities_with_comp2(comp_type1: Script, comp_type2: Script) -> Array[Entity]:
	var aux: Array[Entity] = []
	var comp1_dict = ComponentRegistry.get_component_registry().get(comp_type1)
	var comp2_dict = ComponentRegistry.get_component_registry().get(comp_type2)

	for entity_uid in comp1_dict.keys():
		if not comp2_dict.has(entity_uid):
			continue

		var entity = EntityRegistry.get_entity(entity_uid)
		if not entity:
			push_error("Entidade (uid: %d) deletada dentro de _all_components" % entity_uid)
			return []
		aux.append(entity)

	return aux


## Retorna todas as entidades que tem dois determinados componentes
static func all_entities_with_comp3(comp_type1: Script, comp_type2: Script, comp_type3: Script) -> Array[Entity]:
	var aux: Array[Entity] = []
	var comp1_dict = ComponentRegistry.get_component_registry().get(comp_type1)
	var comp2_dict = ComponentRegistry.get_component_registry().get(comp_type2)
	var comp3_dict = ComponentRegistry.get_component_registry().get(comp_type3)

	for entity_uid in comp1_dict.keys():
		if not comp2_dict.has(entity_uid) or not comp3_dict.has(entity_uid):
			continue

		var entity = EntityRegistry.get_entity(entity_uid)
		if not entity:
			push_error("Entidade (uid: %d) deletada dentro de _all_components" % entity_uid)
			return []
		aux.append(entity)

	return aux


## Retorna todas as entidades que tem dois determinados componentes
static func all_entities_with_comp4(comp_type1: Script, comp_type2: Script, comp_type3: Script, comp_type4: Script) -> Array[Entity]:
	var aux: Array[Entity] = []
	var comp1_dict = ComponentRegistry.get_component_registry().get(comp_type1)
	var comp2_dict = ComponentRegistry.get_component_registry().get(comp_type2)
	var comp3_dict = ComponentRegistry.get_component_registry().get(comp_type3)
	var comp4_dict = ComponentRegistry.get_component_registry().get(comp_type4)

	for entity_uid in comp1_dict.keys():
		if not comp2_dict.has(entity_uid) or not comp3_dict.has(entity_uid) or not comp4_dict.has(entity_uid):
			continue

		var entity = EntityRegistry.get_entity(entity_uid)
		if not entity:
			push_error("Entidade (uid: %d) deletada dentro de _all_components" % entity_uid)
			return []
		aux.append(entity)

	return aux
