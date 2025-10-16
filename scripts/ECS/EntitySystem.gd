extends System
class_name EntitySystem

static func HasComp(entity : Entity, comp_type : Script) -> bool:
	for component in entity.components:
		if component.get_script() == comp_type:
			return true
	return false
	
