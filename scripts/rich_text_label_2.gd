extends RichTextLabel


func _ready() -> void:
	text = str(multiplayer.get_unique_id())
