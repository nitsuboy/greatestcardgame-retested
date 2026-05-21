## Armazena componentes de um mesmo tipo usando Sparse Set.
##
## Estrutura com lookup O(1) e iteração cache-friendly.
## Composta por três arrays paralelas:
## - _sparse:  entity_id → índice no _dense (ou -1 se ausente)
## - _dense:   entity_ids em ordem de inserção
## - _data:    componentes na mesma ordem do _dense
##
## A remoção usa swap-with-last para evitar shifting:
## copia o último elemento para a posição removida e dá resize.
class_name SparseSet
extends RefCounted

var _sparse: PackedInt32Array
var _dense: PackedInt32Array
var _data: Array[Resource]


func _init(capacity: int = 64) -> void:
	_sparse.resize(capacity)
	_sparse.fill(-1)


## Garante que _sparse tem espaço para o entity_id.
## Redimensiona em blocos de 64 slots, preenchendo novos com -1.
func ensure_space(entity: int) -> void:
	if entity >= _sparse.size():
		var old = _sparse.size()
		_sparse.resize(entity + 64)
		for i in range(old, _sparse.size()):
			_sparse[i] = -1


## Retorna true se a entidade possui este componente no storage.
##
## Verifica três condições:
## 1. entity_id está dentro do range do sparse
## 2. sparse[entity] >= 0 (índice válido no dense)
## 3. dense[índice] == entity (consistência — evita falsos positivos
##    após entidade ser destruída e o ID reutilizado com geração diferente)
func has(entity: int) -> bool:
	if entity >= _sparse.size():
		return false
	var idx = _sparse[entity]
	return idx >= 0 and idx < _dense.size() and _dense[idx] == entity


## Adiciona um componente à entidade.
## O(1) amortizado — append no dense + atualiza sparse.
func add(entity: int, component: Resource) -> void:
	ensure_space(entity)
	assert(not has(entity), "entity already has this component")
	var idx = _dense.size()
	_dense.append(entity)
	_data.append(component)
	_sparse[entity] = idx


## Retorna o componente da entidade. O(1).
func get_(entity: int) -> Resource:
	assert(has(entity), "entity does not have this component")
	return _data[_sparse[entity]]


## Remove o componente da entidade. O(1).
##
## Swap-with-last: copia o último elemento do dense para a
## posição sendo removida, depois reduz o tamanho. Evita
## ter que shifting todos os elementos seguintes.
func remove(entity: int) -> void:
	assert(has(entity), "entity does not have this component")
	var idx = _sparse[entity]
	var last = _dense.size() - 1

	if idx != last:
		var last_entity = _dense[last]
		_dense[idx] = last_entity
		_data[idx] = _data[last]
		_sparse[last_entity] = idx

	_dense.resize(last)
	_data.resize(last)
	_sparse[entity] = -1


## Retorna todas as entidades que possuem este componente (array denso).
## Usado pelo sistema de Query para iteração.
func get_all_entities() -> PackedInt32Array:
	return _dense


## Retorna todos os componentes deste tipo (alinhado com get_all_entities).
func get_all_data() -> Array[Resource]:
	return _data


## Número de entidades com este componente.
func size() -> int:
	return _dense.size()


## Remove todas as entidades e componentes deste storage.
func clear() -> void:
	_dense.clear()
	_data.clear()
	_sparse.fill(-1)
