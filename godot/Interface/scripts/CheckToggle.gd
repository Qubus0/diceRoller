tool
extends PanelContainer
class_name CheckToggle

onready var button := $Button
onready var label := $VBox/HBox/Label
onready var handle_position := $VBox/HBox/Toggle/Background/HandlePosition
onready var background := $VBox/HBox/Toggle/Background
onready var background_state := $VBox/HBox/Toggle/Background/State
onready var handle := $VBox/HBox/Toggle/Background/HandlePosition/Handle
onready var handle_state := $VBox/HBox/Toggle/Background/HandlePosition/State

export var label_text := '' setget set_label_text
export var show_label_left := false setget set_show_label_left
export var pressed := false setget set_pressed
export var disabled := false setget set_disabled
var hover := false
var focus := false
export var min_height := 20 setget set_min_height

var toggle_spacing := 10
var toggle_aspect := 200

var background_checked: StyleBox = null
var background_focus: StyleBox = null
var background_hover: StyleBox = null
var background_normal: StyleBox = null
var background_disabled: StyleBox = null

var handle_checked: StyleBox = null
var handle_focus: StyleBox = null
var handle_hover: StyleBox = null
var handle_normal: StyleBox = null
var handle_disabled: StyleBox = null

signal toggled(button_pressed)


func _ready() -> void:
	button.disabled = disabled
	button.pressed = pressed

	sync_theme()
	set_label_text(label_text)
	set_show_label_left(show_label_left)
	style_state()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		sync_theme()


func set_min_height(height: int) -> void:
	min_height = height
	var size = Vector2(min_height * float(toggle_aspect)/100.0, min_height)
	$VBox/HBox/Toggle.rect_min_size = size


func set_label_text(text: String) -> void:
	label_text = text
	if label:
		label.text = text


func set_show_label_left(show_left: bool) -> void:
	show_label_left = show_left
	if not label:
		return
	if show_left:
		$VBox/HBox.move_child(label, 0)
	else:
		$VBox/HBox.move_child(label, 1)


func set_pressed(is_pressed: bool) -> void:
	pressed = is_pressed
	if button:
		button.pressed = is_pressed
	style_state()


func set_disabled(is_disabled: bool) -> void:
	disabled = is_disabled
	if button:
		button.disabled = is_disabled
	style_state()


func _on_Button_toggled(button_pressed: bool) -> void:
	set_pressed(button_pressed)
	emit_signal('toggled', button_pressed)


func _on_Button_focus_entered() -> void:
	focus = true
	style_state()


func _on_Button_focus_exited() -> void:
	focus = false
	style_state()


func _on_Button_mouse_entered() -> void:
	hover = true
	style_state()


func _on_Button_mouse_exited() -> void:
	hover = false
	style_state()


func style_state() -> void:
	if not handle or not background or not toggle_aspect or not toggle_spacing or not handle_position or not handle_state or not background_state:
		return

	var has_state := false
	var handle_style: StyleBox = handle_normal
	var handle_state_style: StyleBox = null
	var background_style: StyleBox = background_normal
	var background_state_style: StyleBox = null
	handle_position.alignment_horizontal = HALIGN_LEFT
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	if pressed:
		handle_position.alignment_horizontal = HALIGN_RIGHT
		handle_style = handle_checked
		background_style = background_checked

	if hover:
		has_state = true
		handle_state_style = handle_hover
		background_state_style = background_hover

	if focus:
		has_state = true
		handle_state_style = handle_focus
		background_state_style = background_focus

	if disabled:
		has_state = true
		handle_state_style = handle_disabled
		background_state_style = background_disabled
		button.mouse_default_cursor_shape = Control.CURSOR_ARROW


	handle.add_stylebox_override('panel', handle_style)
	background.add_stylebox_override('panel', background_style)
	if has_state:
		handle_state.show()
		background_state.show()
		handle_state.add_stylebox_override('panel', handle_state_style)
		background_state.add_stylebox_override('panel', background_state_style)
	else:
		handle_state.hide()
		background_state.hide()


func sync_theme() -> void:
	toggle_spacing = get_constant('toggle_spacing', 'CheckToggle')
	$VBox/HBox.add_constant_override('separation', toggle_spacing)
	toggle_aspect = get_constant('toggle_aspect', 'CheckToggle')
	$VBox/HBox/Toggle.ratio = float(toggle_aspect)/100.0

	background_checked = get_stylebox('background_checked', 'CheckToggle')
	background_focus = get_stylebox('background_focus', 'CheckToggle')
	background_hover = get_stylebox('background_hover', 'CheckToggle')
	background_normal = get_stylebox('background_normal', 'CheckToggle')
	background_disabled = get_stylebox('background_disabled', 'CheckToggle')

	handle_checked = get_stylebox('handle_checked', 'CheckToggle')
	handle_focus = get_stylebox('handle_focus', 'CheckToggle')
	handle_hover = get_stylebox('handle_hover', 'CheckToggle')
	handle_normal = get_stylebox('handle_normal', 'CheckToggle')
	handle_disabled = get_stylebox('handle_disabled', 'CheckToggle')


