## Gerencia IDs de entidades usando generational index.
##
## Cada entity_id é um inteiro de 30 bits:
## - bits 21..0 (22 bits): índice no array de gerações (~4M slots)
## - bits 29..22 (8 bits): geração (256 ciclos por slot)
##
## Quando uma entidade é destruída, sua geração é incrementada.
## IDs reciclados recebem o mesmo índice mas com geração nova,
## então referências antigas são detectadas como inválidas.
class_name EntityManager
extends RefCounted

const INDEX_BITS: int = 22
const GEN_BITS: int = 8
const INDEX_MASK: int = (1 << INDEX_BITS) - 1
const GEN_MASK: int = (1 << GEN_BITS) - 1
const GEN_SHIFT: int = INDEX_BITS

var _generations: PackedInt32Array
var _free_list: PackedInt32Array
var _living_count: int = 0


## Cria uma nova entidade e retorna seu ID.
##
## Reusa índices de entidades destruídas (free list) quando
## disponível. Caso contrário, expande o array de gerações.
func create() -> int:
	var index: int
	if _free_list.size() > 0:
		index = _free_list[_free_list.size() - 1]
		_free_list.resize(_free_list.size() - 1)
	else:
		index = _generations.size()
		_generations.append(0)

	_generations[index] = _generations[index] & GEN_MASK
	_living_count += 1
	return _pack(index, _generations[index])


## Força a criação de uma entidade com um ID específico.
## Usado pelo Replicator para recriar entidades no cliente
## com o mesmo ID que foram criadas no servidor.
func force_create(entity: int) -> void:
	var index = entity & INDEX_MASK
	var gen = (entity >> GEN_SHIFT) & GEN_MASK
	while index >= _generations.size():
		_generations.append(0)
	_generations[index] = gen & GEN_MASK
	_living_count += 1


## Verifica se uma entidade ainda existe (não foi destruída).
##
## Compara a geração armazenada com a geração no ID.
## Se foram destruídas e recriadas, a geração será diferente.
func exists(entity: int) -> bool:
	var index = _unpack_index(entity)
	var gen = _unpack_gen(entity)
	return index < _generations.size() and _generations[index] == gen


## Destroi uma entidade: incrementa a geração e adiciona
## o índice à free list para reuso futuro.
func destroy(entity: int) -> void:
	assert(exists(entity), "destroying non-existent entity")
	var index = _unpack_index(entity)
	_generations[index] = (_generations[index] + 1) & GEN_MASK
	_free_list.append(index)
	_living_count -= 1


## Número de entidades vivas atualmente.
func living_count() -> int:
	return _living_count


## Empacota índice e geração em um único inteiro de 30 bits.
func _pack(index: int, generation: int) -> int:
	return (generation << GEN_SHIFT) | index


## Extrai o índice (22 bits baixos) do entity_id.
func _unpack_index(entity: int) -> int:
	return entity & INDEX_MASK


## Extrai a geração (8 bits seguintes) do entity_id.
func _unpack_gen(entity: int) -> int:
	return (entity >> GEN_SHIFT) & GEN_MASK
