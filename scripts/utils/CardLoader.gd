extends Node

class_name CardLoader

static func LoadCardsFromFile(path : String) -> Array[CardData]:
	
	var result : Array[CardData] = []
	
	var file : FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open card JSON at %s" % path)
		return result
	
	var raw_json : String = file.get_as_text()
	var parsed : Variant = JSON.parse_string(raw_json)
	
	if typeof(parsed) != TYPE_ARRAY:
		push_error("Invalid JSON format: expected an array")
		return result
	
	for entry in parsed:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		
		var card : CardData = CardData.new()
		card.type = entry.get("type", "")
		card.description = entry.get("description", "")
		card.test_requirements = entry.get("test_requirements", {})
		card.front_image = null #Will change latter
		
		result.append(card)
	
	return result
