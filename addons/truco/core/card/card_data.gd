## Serializable card data (Resource).
##
## Contains the list of components that will be added to the
## entity when the card is instantiated. Can be saved
## in .tres files to define decks.
class_name CardData
extends Resource

## Components that make up this card (added to the entity).
@export var components: Array[Component]
