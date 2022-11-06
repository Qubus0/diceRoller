extends HBoxContainer


var body_material := preload('res://dice/materials/Body.material')
var body_locked_material := preload('res://dice/materials/BodyLocked.material')
var number_material := preload('res://dice/materials/Numbers.material')
var outline_shader := preload('res://dice/materials/outline.tres')


func apply_settings():
	for setting in SettingsData.settings:
		if "show_input_d" in setting:
			var dice_toggle_name = setting.trim_prefix("show_input_").to_upper() + "Toggle"
			var toggle = $Margin1/DiceTypes.get_node(dice_toggle_name)
			toggle.pressed = SettingsData.get_setting(setting)
		if setting == "use_commands":
			$Margin1/DiceTypes/CommandsToggle.pressed = SettingsData.get_setting(setting)
		if "_color" in setting:
			self.call("apply_" + setting, SettingsData.get_setting(setting))
			match setting:
				"body_color":
					$"Margin2/DiceTheme/ColorPickers/Container1/Body".color = body_material.albedo_color
				"number_color":
					$"Margin2/DiceTheme/ColorPickers/Container2/Numbers".color = number_material.albedo_color
				"border_color":
					$"Margin2/DiceTheme/ColorPickers/Container3/Border".color = outline_shader.get_shader_param('border_color')


func _on_CommandsToggle_toggled(button_pressed: bool) -> void:
	for toggle in $Margin1/DiceTypes.get_children():
		if toggle is CheckToggle and not toggle == $Margin1/DiceTypes/CommandsToggle:
			toggle.disabled = button_pressed
	SettingsData.set_setting("use_commands", button_pressed)


func _on_D4Toggle_toggled(button_pressed: bool) -> void:
	SettingsData.set_setting("show_input_d4", button_pressed)


func _on_D6Toggle_toggled(button_pressed: bool) -> void:
	SettingsData.set_setting("show_input_d6", button_pressed)


func _on_D8Toggle_toggled(button_pressed: bool) -> void:
	SettingsData.set_setting("show_input_d8", button_pressed)


func _on_D10Toggle_toggled(button_pressed: bool) -> void:
	SettingsData.set_setting("show_input_d10", button_pressed)


func _on_D12Toggle_toggled(button_pressed: bool) -> void:
	SettingsData.set_setting("show_input_d12", button_pressed)


func _on_D20Toggle_toggled(button_pressed: bool) -> void:
	SettingsData.set_setting("show_input_d20", button_pressed)


func _on_Body_color_changed(color: Color) -> void:
	SettingsData.set_setting("body_color", color)
	apply_body_color(color)


func _on_Numbers_color_changed(color: Color) -> void:
	SettingsData.set_setting("number_color", color)
	apply_number_color(color)


func _on_Border_color_changed(color: Color) -> void:
	SettingsData.set_setting("border_color", color)
	apply_border_color(color)


func apply_body_color(color: Color) -> void:
	body_material.albedo_color = color
	body_locked_material.albedo_color = color


func apply_number_color(color: Color) -> void:
	number_material.albedo_color = color


func apply_border_color(color: Color) -> void:
	outline_shader.set_shader_param('border_color', color)



