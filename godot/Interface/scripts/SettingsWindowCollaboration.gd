extends MarginContainer



func _on_FeatureRequest_pressed() -> void:
	# warning-ignore:return_value_discarded
	OS.shell_open('https://github.com/Qubus0/diceRoller/issues')


func _on_Github_pressed() -> void:
	# warning-ignore:return_value_discarded
	OS.shell_open('https://github.com/Qubus0/diceRoller')
