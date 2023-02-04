extends LineEdit

var exited := true


func _input(event) -> void:
	if event is InputEventMouseButton and exited:
		release_focus()
		return

	if event is InputEventKey and event.scancode == KEY_ESCAPE:
		release_focus()


func _on_mouse_exited() -> void:
	exited = true


func _on_mouse_entered() -> void:
	exited = false


