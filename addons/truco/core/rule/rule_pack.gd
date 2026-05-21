## Package of validation rules.
## Composes multiple rules into a single component that can be
## added to an entity.
class_name RulePack
extends Component

## List of rules in this package.
@export var rules: Array[Rule] = []
