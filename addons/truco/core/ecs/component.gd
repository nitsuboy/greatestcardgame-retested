## Classe base para todos os componentes do ECS.
##
## Componentes são Resources, o que permite serialização automática
## e uso com o sistema de recursos do Godot (podem ser salvos em .tres).
##
## Para criar um novo componente, estenda esta classe e declare
## propriedades @export ou públicas (sem prefixo _):
##     class_name MeuComponent extends Component
##     @export var vida: int
##
## Propriedades com prefixo _ são ignoradas por to_dict/from_dict.
class_name Component
extends Resource


## Controla se este componente é incluído na serialização
## do Replicator. Retorne false para componentes locais
## que não devem ser sincronizados via rede (ex: NodeRef).
func should_serialize() -> bool:
	return true


## Converte as propriedades públicas do componente em um Dictionary
## para transmissão via rede.
##
## Suporta: int, float, String, bool, Vector2 (como {"x":, "y":}).
## Tipos complexos são convertidos com str().
func to_dict() -> Dictionary:
	var dict = {}
	var props = get_property_list()
	for prop in props:
		var name = prop["name"]
		if (
			name.begins_with("_")
			or (
				name
				in [
					"script",
					"resource_local_to_scene",
					"resource_name",
					"resource_scene_unique_id",
					"resource_path"
				]
			)
		):
			continue

		var value = get(name)
		match prop["type"]:
			TYPE_NIL:
				continue
			TYPE_VECTOR2:
				dict[name] = {"x": value.x, "y": value.y}
			TYPE_INT, TYPE_FLOAT, TYPE_STRING:
				dict[name] = value
			TYPE_BOOL:
				dict[name] = value
			_:
				dict[name] = str(value)
	return dict


## Restaura as propriedades do componente a partir de um Dictionary.
## Operação inversa de to_dict().
func from_dict(data: Dictionary) -> void:
	for key in data.keys():
		if key in self:
			var value = data[key]
			if typeof(value) == TYPE_DICTIONARY and value.has("x"):
				set(key, Vector2(value["x"], value["y"]))
			else:
				set(key, value)
