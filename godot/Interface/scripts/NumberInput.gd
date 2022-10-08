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


func get_number() -> int:
	var num := int(text)
	if num and num > 0:
		return num
	return 1


func _on_NumberInput_text_changed(new_text: String) -> void:
	var old_position := caret_position
	set_text(str(int(new_text)) if new_text and int(new_text) else '')
	caret_position = old_position

