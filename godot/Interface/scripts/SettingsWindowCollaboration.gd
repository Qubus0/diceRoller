extends MarginContainer


func _on_Feedback_pressed() -> void:
	# warning-ignore:return_value_discarded
	OS.shell_open("https://discord.com/invite/h7udm2T2GT")


func _on_Contribute_pressed() -> void:
	# warning-ignore:return_value_discarded
	OS.shell_open('https://github.com/Qubus0/diceRoller')


func _on_BugReport_pressed() -> void:
	# warning-ignore:return_value_discarded
	OS.shell_open('https://github.com/Qubus0/diceRoller/issues')

