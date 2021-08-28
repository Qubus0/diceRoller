extends LineEdit

var exited = false
func _input(event):
	if event is InputEventMouseButton and exited:
		release_focus()
		return

	if event is InputEventKey and \
	(event.scancode == KEY_M or
	event.scancode == KEY_N or
	event.scancode == KEY_C or
	event.scancode == KEY_L or
	event.scancode == KEY_ESCAPE or
	event.scancode == KEY_SPACE):
		release_focus()


func _on_DiceMax_mouse_exited() -> void:
	exited = true

func _on_DiceMax_mouse_entered() -> void:
	exited = false

