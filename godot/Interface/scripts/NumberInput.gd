extends LineEdit

var exited := true


func _input(event) -> void:
	if event is InputEventMouseButton and exited:
		release_focus()
		return

	if event is InputEventKey and event.scancode == KEY_ESCAPE:
		release_focus()

	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_WHEEL_UP:
				modify_number(-1)
			elif event.button_index == BUTTON_WHEEL_DOWN:
				modify_number(1)


func _on_mouse_exited() -> void:
	exited = true


func _on_mouse_entered() -> void:
	exited = false


func modify_number(step: int) -> void:
	var new_num := get_number() + step
	if new_num > 0:
		set_text(String(new_num))


func get_number() -> int:
	var num := int(text)
	if num and num > 0:
		return num
	return 1


func _on_NumberInput_text_changed(new_text: String) -> void:
	var old_position := caret_position
	set_text(str(int(new_text)) if new_text and int(new_text) else '')
	caret_position = old_position

