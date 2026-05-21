## Component that enables hover on cards.
## Controls the zoom applied when hovering and whether it is locked.
class_name HoverableComponent
extends Component

## Zoom factor when hovering.
@export var zoom: float = 1.2
## If true, hover has no effect.
@export var locked: bool = false
