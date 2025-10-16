extends Node

class_name teste

func _ready() -> void:
	var ent = Entity.new()
	print(ent.id)
	
	var ent2 = Entity.new()
	print(ent2.id)
	
	ent.components.append(CompA.new())
	print(EntitySystem.HasComp(ent, CompA))
	
	print(EntitySystem.HasComp(ent2, CompA))

class CompA extends Component:
	var numero = 10
