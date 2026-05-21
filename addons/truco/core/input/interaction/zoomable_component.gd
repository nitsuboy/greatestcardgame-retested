## Component that allows a card to be zoomed (magnified).
## Used to inspect cards without dragging them.
class_name ZoomableComponent
extends Component

## Zoom factor when clicking the card.
@export var zoom: float = 1.5
## Cursor shape when hovering over the card.
@export var cursor_shape: int = Control.CURSOR_HELP
