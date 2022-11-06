extends MarginContainer


func apply_settings():
	for setting in SettingsData.settings:
		match setting:
			"invert_scroll":
				$VBox/Grid/InvertScroll.pressed = SettingsData.get_setting(setting)
			"invert_resize":
				$VBox/Grid/InvertResize.pressed = SettingsData.get_setting(setting)
			"gravity":
				$VBox/HBoxContainer/Gravity.value = SettingsData.get_setting(setting, 10)


func _on_InvertScroll_toggled(button_pressed) -> void:
	SettingsData.set_setting("invert_scroll", button_pressed)


func _on_InvertResize_toggled(button_pressed) -> void:
	SettingsData.set_setting("invert_resize", button_pressed)


func _on_AllowLockedMove_toggled(button_pressed) -> void:
	SettingsData.set_setting("allow_locked_move", button_pressed)


func _on_Gravity_value_changed(value: float) -> void:
	SettingsData.set_setting("gravity", value)


