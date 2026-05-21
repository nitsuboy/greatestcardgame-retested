## Component that allows a card to be dragged.
## Controls visual offset, zoom during drag, and lock state.
class_name DraggableComponent
extends Component

## Visual offset during drag.
@export var offset: Vector2 = Vector2.ZERO
## Zoom applied during drag.
@export var zoom: float = 1.2
## Whether currently being dragged.
@export var dragging: bool = false
## If true, cannot be dragged.
@export var locked: bool = false
## Cursor shape when hovering over the card.
@export var cursor_shape: int = Control.CURSOR_POINTING_HAND
