extends Spatial

var global_area_scale := .2
var scale_step_size := .02

var size_up := false
var zoom_in := false


func _ready() -> void:
	randomize()


func _unhandled_input(event: InputEvent) -> void:
	handle_zoom_event(event)


func handle_zoom_event(event: InputEvent) -> void:
	if not event is InputEventWithModifiers:
		return

	var scroll_invertion := -1.0 if SettingsData.get_setting("invert_scroll") else 1.0
	var resize_invertion := -1.0 if SettingsData.get_setting("invert_resize") else 1.0
	if event is InputEventMagnifyGesture:
		if event.alt or event.shift:
			if event.factor > 1:
				size_up = true
				resize((event.factor -1) * 5)
			elif event.factor < 1:
				size_up = false
				resize((event.factor -1) * -5)
		else:
			if event.factor > 1:
				zoom_in = true
				zoom((event.factor -1) * 5)
			elif event.factor < 1:
				zoom_in = false
				zoom((event.factor -1) * -5)

	if event is InputEventMouseButton:
		if event.alt or event.shift:
			if event.is_action_pressed('scroll_up'):
				size_up = true
				resize(resize_invertion)
			elif event.is_action_pressed('scroll_down'):
				size_up = false
				resize(resize_invertion)
		else:
			if event.is_action_pressed('scroll_up'):
				zoom_in = true
				zoom(scroll_invertion)
			elif event.is_action_pressed('scroll_down'):
				zoom_in = false
				zoom(scroll_invertion)


func _on_Interface_area_resized(_size_up: bool, pressed: bool) -> void:
	size_up = _size_up
	if pressed:
		resize()
		$Box/ResizeTicks.start()
	else:
		$Box/ResizeTicks.stop()


func _on_ResizeTicks_timeout() -> void:
	resize()


func resize(resize_factor: float = 1.0) -> void:
	if size_up and global_area_scale < 1.4:
		global_area_scale += scale_step_size * resize_factor
	elif global_area_scale > .15:
		global_area_scale -= scale_step_size * resize_factor
	$Box.scale = Vector3(global_area_scale, global_area_scale, global_area_scale)

	for die in $DiceManager.get_children():
		die.set_sleeping(false)


func _on_Interface_camera_zoomed(_zoom_in: bool, pressed: bool) -> void:
	zoom_in = _zoom_in
	if pressed:
		zoom()
		$Camera/ZoomTicks.start()
	else:
		$Camera/ZoomTicks.stop()


func _on_ZoomTicks_timeout() -> void:
	zoom()


func zoom(zoom_factor: float = 1.0) -> void:
	zoom_factor += $Camera.translation.length() / 200
	var offset: Vector3 = $Camera.translation.normalized() * zoom_factor
	if zoom_in:
		if $Camera.translation.length() > 4: # minimum zoom
			$Camera.translation -= offset
	else:
		if $Camera.translation.length() < 60: # maximum
			$Camera.translation += offset


