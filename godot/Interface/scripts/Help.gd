extends ColorRect


func _ready() -> void:
	for help_window in get_children():
		help_window.connect('moved', self, '_on_help_window_moved')


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.scancode == KEY_ESCAPE:
		hide()


func _on_Help_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		hide()


func _on_help_window_moved(help_window: Control) -> void:
	move_child(help_window, get_child_count() -1)
