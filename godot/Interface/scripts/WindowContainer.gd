extends ColorRect
class_name WindowContainer


func _ready() -> void:
	for window in get_children():
		if window is Window:
			window.connect('moved', self, '_on_window_moved')
	connect("gui_input", self, "_on_gui_input")

	if not visible:
		set_pause(self, true)


func _unhandled_key_input(event: InputEventKey) -> void:
	if event.scancode == KEY_ESCAPE:
		hide()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		hide()


func _on_window_moved(window: Window) -> void:
	move_child(window, get_child_count() -1)


func show() -> void:
	set_pause(self, false)
	grab_focus()
	visible = true


func hide() -> void:
	if not visible:
		return
	if name == "Settings":
		SettingsData.save_settings()
	set_pause(self, true)
	visible = false


func set_pause(node: Node, pause: bool) -> void:
	if node.pause_mode == PAUSE_MODE_INHERIT or node.pause_mode == PAUSE_MODE_STOP:
		node.set_process(!pause)
		node.set_physics_process(!pause)
	for child in node.get_children():
		set_pause(child, pause)
