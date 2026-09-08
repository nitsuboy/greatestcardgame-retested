## Component that allows a card to be clicked.
## Emits on_card_clicked when pressed (see InteractionSystem).
class_name ClickableComponent
extends Component

## Cursor shape when hovering over the card.
@export var cursor_shape: int = Control.CURSOR_POINTING_HAND