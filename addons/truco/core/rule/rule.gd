## Abstract base class for validation rules.
##
## Each rule decides if it applies to an action (applies_to) and
## validates whether the action is allowed (validate).
##
## Rules are composed via RulePack and executed by the
## game's ValidationSystem.
@abstract class_name Rule
extends Resource

## Returns true if this rule applies to the action.
@abstract func applies_to(action: String, data: Dictionary) -> bool

## Validates the action. Returns a dictionary with the result.
@abstract func validate(sender: int, data: Dictionary, context: Dictionary) -> Dictionary
