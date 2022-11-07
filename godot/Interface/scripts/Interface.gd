extends Control

onready var dice_types: Array = $'/root/main/DiceManager'.dice_type_strings
var selected_type: String = 'd6' setget set_selected_type
var max_addable : Dictionary


signal camera_zoomed(zoom_in, pressed)
signal area_resized(size_up, pressed)

signal add_die(type)
signal clear_dice(type)
signal roll_all
signal roll_invalid
signal lock_valid


func _ready() -> void:
	SettingsData.listen(self, "_on_dice_setting_changed")
	for type in dice_types:
		var select := preload('res://Interface/DiceSelect.tscn').instance()
		select.name = type
		select.type = type
		# warning-ignore:return_value_discarded
		select.connect('add_dice', self, '_on_DiceSelectAdd_button_down')
		# warning-ignore:return_value_discarded
		select.connect('remove_dice', self, '_on_DiceSelectRemove_button_down')
		$Layout/Interactions/DiceSelects.add_child(select)
	apply_settings_recursive(self)
	SettingsData.connect("settings_saved", self, "toast_message", ["Saved!", 0, 2])


func _unhandled_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event and key_event.is_action_pressed('number_shortcut'): # 1-9
		var type_index := clamp(int(key_event.as_text()), 0, dice_types.size())
		var type: String = dice_types[type_index - 1] # start at 0
		self.selected_type = type
		emit_signal('add_die', selected_type)


func toast_message(message: String, delay: float = 0, lifetime: float = 0) -> void:
	var toast: Toast = preload("res://Interface/Toast.tscn").instance()
	toast.message = message
	toast.delay = delay
	toast.lifetime = lifetime
	if $Toasts.get_child_count() > 0:
		$Toasts.remove_child($Toasts.get_children()[0])
	$Toasts.add_child(toast)


func apply_settings_recursive(node: Node) -> void:
	if node.has_method("apply_settings"):
		node.apply_settings()
	for child in node.get_children():
		apply_settings_recursive(child)


func set_selected_type(type: String) -> void:
	selected_type = type
	$Layout/Interactions/Buttons/Buttons/AddDie.icon = \
	load('res://Interface/Icons/%s.png' % type)


func _on_DiceSelectAdd_button_down(type: String, amount: int) -> void:
	self.selected_type = type
	if max_addable.has(selected_type):
		max_addable[selected_type] += amount
	else:
		max_addable[selected_type] = amount
	add_multiple(selected_type)


func add_multiple(type: String) -> void:
	if not max_addable or not max_addable.has(type):
		return

	while max_addable[type] > 0:
		max_addable[type] -= 1
		emit_signal('add_die', type)
		yield(get_tree().create_timer(.0003), 'timeout')


func _on_dice_setting_changed(setting: String, value):
	if "show_input_d" in setting:
		var select: Control = $Layout/Interactions/DiceSelects.get_node(setting.trim_prefix("show_input_"))
		select.visible = value
	if setting == "use_commands":
		$Layout/Interactions/DiceSelects.visible = not value
		$DiceCommands.visible = SettingsData.get_setting(setting)


func apply_settings():
	for setting in SettingsData.settings:
		if "show_input_d" in setting:
			var dice_select_name = setting.trim_prefix("show_input_")
			var select = $Layout/Interactions/DiceSelects.get_node(dice_select_name)
			select.visible = SettingsData.get_setting(setting)
		if setting == "use_commands":
			$Layout/Interactions/DiceSelects.visible = not SettingsData.get_setting(setting)
			$DiceCommands.visible = SettingsData.get_setting(setting)


func _on_DiceSelectRemove_button_down(type: String) -> void:
	emit_signal('clear_dice', type)
	max_addable[type] = 0


func _on_AddDie_button_down() -> void:
	emit_signal('add_die', selected_type)


func _on_ClearDice_button_down() -> void:
	for type in max_addable:
		max_addable[type] = 0
	emit_signal('clear_dice', '')


func _on_Roll_button_down() -> void:
	emit_signal('roll_all')


func _on_RollInvalidDice_button_down() -> void:
	emit_signal('roll_invalid')


func _on_LockValidDice_button_down() -> void:
	emit_signal('lock_valid')


func _on_Settings_pressed() -> void:
	$Settings.visible = not $Settings.visible


func _on_Help_pressed() -> void:
	$Help.visible = not $Help.visible
	if $Help.visible:
		for helpWindow in $Help.get_children():
			helpWindow.show()


func _on_SizeUp_button_down() -> void:
	emit_signal('area_resized', true, true)


func _on_SizeUp_button_up() -> void:
	emit_signal('area_resized', true, false)


func _on_SizeDown_button_down() -> void:
	emit_signal('area_resized', false, true)


func _on_SizeDown_button_up() -> void:
	emit_signal('area_resized', false, false)


func _on_ZoomIn_button_down() -> void:
	emit_signal('camera_zoomed', true, true)


func _on_ZoomIn_button_up() -> void:
	emit_signal('camera_zoomed', true, false)


func _on_ZoomOut_button_down() -> void:
	emit_signal('camera_zoomed', false, true)


func _on_ZoomOut_button_up() -> void:
	emit_signal('camera_zoomed', false, false)

