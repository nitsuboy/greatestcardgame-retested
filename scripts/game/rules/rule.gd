@abstract class_name Rule
extends Resource

@abstract func applies_to(action: String, data: Dictionary) -> bool

@abstract func validate(sender: int, data: Dictionary, context: Dictionary) -> Dictionary
