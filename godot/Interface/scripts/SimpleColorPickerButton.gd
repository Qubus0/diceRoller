tool
extends Button

class_name SimpleColorPickerButton

signal popup_hide
signal color_changed(color)

export var default_color := Color.darkgray
var color : Color setget set_colors

var panel : PopupPanel
var color_picker : ColorPicker


func _ready() -> void:
	color = default_color
	# Add panel with color picker
	panel = PopupPanel.new()
	add_child(panel)
	color_picker = ColorPicker.new()
	color_picker.color = color
	panel.add_child(color_picker)
	color_picker = simplify_color_picker(color_picker)

	# warning-ignore:return_value_discarded
	color_picker.connect("color_changed", self, "set_colors")
	# warning-ignore:return_value_discarded
	panel.connect("popup_hide", self, "panel_closed")

	$ColorRect.color = color


func simplify_color_picker(picker: ColorPicker) -> ColorPicker:
	# hide advanced picker sliders
	for n in range(3, picker.get_child_count()):
		picker.get_child(n).hide()

	# hide color dropper
	picker.get_child(1).get_child(1).hide()

	# move hex code input in place of picker
	var line_edit: LineEdit = picker.get_child(4).get_child(4).get_child(3)
	line_edit.show()
	line_edit.align = ALIGN_RIGHT
	line_edit.get_parent().remove_child(line_edit)
	picker.get_child(1).add_child(line_edit)

	# size the picker area down
	var center_size: Control = picker.get_child(0).get_child(0)
	center_size.rect_min_size = self.rect_size * 2.5
	center_size.rect_size = Vector2(0, 0)
	var hue_size: Control = picker.get_child(0).get_child(1)
	hue_size.rect_min_size.x = self.rect_size.x * 0.4
	hue_size.rect_size.x = 0

	return picker


func _on_SimpleColorPickerButton_pressed() -> void:
	color_picker.color = color
	show_panel()


func show_panel() -> void:
	var button_center_bottom := Vector2(self.rect_size.x/2, self.rect_size.y) + self.rect_global_position
	var panel_center_top := Vector2(self.panel.rect_size.x/2, 0)
	var offset := Vector2(0, self.rect_size.y/4)
	panel.rect_position = button_center_bottom - panel_center_top + offset
	panel.popup()


func panel_closed() -> void:
	release_focus()
	emit_signal("popup_hide")


func set_colors(_color: Color) -> void:
	if not Engine.editor_hint:
		emit_signal("color_changed", _color)
	$ColorRect.color = _color
	color = _color


func _on_Reset_pressed() -> void:
	self.color = default_color
