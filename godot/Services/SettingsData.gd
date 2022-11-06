extends Node


var setting_path := "user://settings.json"
var settings := {}

signal setting_changed(setting, value)


func _ready() -> void:
	load_settings()


func save_settings() -> void:
	var file := File.new()
	file.open(setting_path, File.WRITE)
	file.store_string(JSON.print(settings))
	file.close()


func load_settings() -> void:
	var file := File.new()
	if file.file_exists(setting_path):
		file.open(setting_path, File.READ)
		settings = parse_json(file.get_as_text())
		file.close()
	for setting in settings:
		if "color" in setting:
			settings[setting] = str2var("Color(" + settings[setting] + ")")


func set_setting(setting: String, value) -> void:
	settings[setting] = value
	emit_signal("setting_changed", setting, value)


func get_setting(setting: String, default = null):
	if setting_exists(setting):
		return settings[setting]
	return default


func setting_exists(setting: String) -> bool:
	return settings.has(setting)


func listen(node: Node, method: String) -> void:
	if node.has_method(method):
		connect("setting_changed", node, method)
