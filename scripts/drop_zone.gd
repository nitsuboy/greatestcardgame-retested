class_name DropZone
extends CollisionShape2D

@export var who_to_apply: Node
var global_rect: Rect2

#TODO: fazer dropzones em entidades para tirar esse código duplicado

var components: Array[Component] = []

## Retorna verdadeiro se a drop zone tem um componente de determinado tipo, falso se não
static func has_comp(dropzone: DropZone, comp_type: Script) -> bool:
	for component in dropzone.components:
		if component.get_script() == comp_type:
			return true
	return false


## Retorna o componente de determinado tipo se a drop zone tiver, caso contrário retorna null
static func get_comp(dropzone: DropZone, comp_type: Script) -> Component:
	for component in dropzone.components:
		if component.get_script() == comp_type:
			return component
	return null


## Remove o componenete de um determinado tipo da drop zone
static func remove_comp(dropzone: DropZone, comp_type: Script) -> void:
	var components_to_remove: Array[Component] = []

	for component in dropzone.components:
		if component.get_script() == comp_type:
			components_to_remove.append(component)

	# teoricamente a lista `components_to_remove` só pode ter um item
	if components_to_remove.size() > 1:
		push_warning(
			"dropzone %s had more than one componente of type: %s!" % [str(dropzone.id), str(comp_type)]
		)

	for component in components_to_remove:
		dropzone.components.erase(component)


## Adiciona um componenete de determinado tipo se a drop zone não tiver um daquele tipo
static func ensure_comp(dropzone: DropZone, comp_type: Script) -> void:
	for component in dropzone.components:
		if component.get_script() == comp_type:
			return

	var new_component: Component = comp_type.new()
	dropzone.components.append(new_component)

func _ready():
	global_rect = shape.get_rect()
