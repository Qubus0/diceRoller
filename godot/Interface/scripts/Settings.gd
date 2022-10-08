extends Control

var body_material := preload('res://dice/materials/Body.material')
var body_locked_material := preload('res://dice/materials/BodyLocked.material')
var number_material := preload('res://dice/materials/Numbers.material')
var outline_shader := preload('res://dice/materials/outline.tres')


func _ready() -> void:
	set_pause($Panel, true)
	$Panel/Margin/Layout/DiceTheme/ColorPickers/Container1/Body.color = body_material.albedo_color
	$Panel/Margin/Layout/DiceTheme/ColorPickers/Container2/Numbers.color = number_material.albedo_color
	$Panel/Margin/Layout/DiceTheme/ColorPickers/Container3/Border.color = outline_shader.get_shader_param('border_color')


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.scancode == KEY_ESCAPE:
		hide()


func _on_Settings_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		hide()


func _on_Close_pressed() -> void:
	hide()


func show() -> void:
	set_pause($Panel, false)
	grab_focus()
	visible = true


func hide() -> void:
	set_pause($Panel, true)
	visible = false


func _on_Body_color_changed(color: Color) -> void:
	body_material.albedo_color = color
	body_locked_material.albedo_color = color


func _on_Numbers_color_changed(color: Color) -> void:
	number_material.albedo_color = color


func _on_Border_color_changed(color: Color) -> void:
	outline_shader.set_shader_param('border_color', color)


func _on_FeatureRequest_pressed() -> void:
	# warning-ignore:return_value_discarded
	OS.shell_open('https://github.com/Qubus0/diceRoller/issues')


func _on_Github_pressed() -> void:
	# warning-ignore:return_value_discarded
	OS.shell_open('https://github.com/Qubus0/diceRoller')


func set_pause(node: Node, pause: bool) -> void:
	if node.pause_mode == PAUSE_MODE_INHERIT or node.pause_mode == PAUSE_MODE_STOP:
		node.set_process(!pause)
		node.set_physics_process(!pause)
		node.set_process_input(!pause)
		node.set_process_internal(!pause)
		node.set_process_unhandled_input(!pause)
		node.set_process_unhandled_key_input(!pause)
	for child in node.get_children():
		set_pause(child, pause)

