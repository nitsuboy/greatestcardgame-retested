## Component that allows a card to be zoomed (magnified).
## Used to inspect cards without dragging them.
class_name ZoomableComponent
extends Component

## Zoom factor when clicking the card.
@export var zoom: float = 1.5
## If true, cannot be zoomed.
@export var locked: bool = false
## Cursor shape when hovering over the card.
@export var cursor_shape: int = Control.CURSOR_HELP
## Cursor shape when "holding" the card.
@export var cursor_shape_hold: int = Control.CURSOR_HELP
