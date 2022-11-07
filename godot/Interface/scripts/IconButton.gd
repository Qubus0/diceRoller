tool
extends TextureButton
# script simulates style colors normally set by a theme
# which are not available for texture buttons
# only works (as expected) with completely white textures

export var icon_color_normal: Color
export var icon_color_disabled: Color
export var icon_color_focus: Color
export var icon_color_hover: Color
export var icon_color_pressed: Color

var press_attempt := false
var pressing_inside := false
var hovering := false
enum draw_modes {NORMAL, DISABLED, HOVER, PRESSED}


func _ready() -> void:
	self_modulate = icon_color_normal
	if disabled:
		self_modulate = icon_color_disabled
	# warning-ignore-all:return_value_discarded
	connect('button_down', self, '_on_button_down')
	connect('button_up', self, '_on_button_up')
	connect('mouse_entered', self, '_on_mouse_entered')
	connect('mouse_exited', self, '_on_mouse_exited')


func _process(_delta: float) -> void:
	match get_draw_mode():
		draw_modes.NORMAL:
			self_modulate = icon_color_normal
			if has_focus():
				self_modulate = icon_color_focus

		draw_modes.PRESSED:
			self_modulate = icon_color_pressed
			if has_focus():
				self_modulate = icon_color_focus

		draw_modes.HOVER:
			self_modulate = icon_color_hover

		draw_modes.DISABLED:
			self_modulate = icon_color_disabled


func _set(property : String, value) -> bool:
	if property == "disabled":
		if value:
			if !toggle_mode:
				pressed = false
			press_attempt = false
			pressing_inside = false

			self_modulate = icon_color_disabled
		else:
			self_modulate = icon_color_normal
	return false


func _on_button_down() -> void:
	press_attempt = true
	pressing_inside = true


func _on_button_up() -> void:
	press_attempt = false
	pressing_inside = false


func _on_mouse_entered() -> void:
	hovering = true


func _on_mouse_exited() -> void:
	hovering = false


func get_draw_mode() -> int:
	if disabled:
		return draw_modes.DISABLED

	if not press_attempt and hovering:
		if pressed:
			return draw_modes.PRESSED
		return draw_modes.HOVER
	else:
		var pressing: bool
		if press_attempt:
			pressing = (pressing_inside || keep_pressed_outside)
			if pressed:
				pressing = not pressed
		else:
			pressing = pressed

		if pressing:
			return draw_modes.PRESSED

	return draw_modes.NORMAL

