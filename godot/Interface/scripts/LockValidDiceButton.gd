extends Button

var locked_icon := preload('res://Interface/Icons/locked.png')
var unlocked_icon := preload('res://Interface/Icons/unlocked.png')


func _on_LockValidDice_toggled(button_pressed: bool) -> void:
	if button_pressed:
		icon = locked_icon
	else:
		icon = unlocked_icon
