@tool

extends EditorScript

class_name CardExporter

@export var input_json_path: String = "res://resources/cards/desafios/cards.json"
@export var output_dir: String = "res://resources/cards/"

func _run() -> void:
	var file : FileAccess = FileAccess.open(input_json_path, FileAccess.READ)
	
	print("%s" % file)
	
	if file == null:
		push_error("Failed to open JSON at %s" % input_json_path)
		return
	
	var raw_json : String = file.get_as_text()
	var parsed : Variant = JSON.parse_string(raw_json)
	
	if typeof(parsed) != TYPE_ARRAY:
		push_error("invalid JSON format: expected an array")
		return
		
	for i in parsed.size():
		var entry : Dictionary = parsed[i]
		
		var card : CardData = CardData.new()
		card.type = "Desafio"
		card.description = entry.get("description", "")
		card.test_requirements = entry.get("test_requirements", {})
		card.front_image = null #Add logic later
		
		var filename : String = "DesafioCard_%02d.tres" % i
		var output_path : String = output_dir + filename
		
		var err := ResourceSaver.save(card, output_path)
		if err != OK:
			push_error("Failed to save: %s" % output_path)
		else:
			print("Saved card: %s" % output_path)
