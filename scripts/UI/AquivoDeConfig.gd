extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"

func _ready() -> void:
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("volume","musica",100)
		config.set_value("volume","sfx",100)
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)

func SalvarConfiguracoes(key:String,value:float) -> void:
	config.set_value("volume",key,value)
	config.save(SETTINGS_FILE_PATH)

func CarregarConfiguracoes() -> Dictionary:
	var audio_settings = {}
	for key in config.get_section_keys("volume"):
		audio_settings[key] = config.get_value("volume",key)
	return audio_settings
