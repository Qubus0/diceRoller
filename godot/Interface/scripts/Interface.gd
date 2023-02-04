extends Control

onready var dice_types: Array = $"/root/main/DiceManager".dice_type_strings
var selected_type: String = "d6" setget set_selected_type



signal camera_zoomed(zoom_in, pressed)
signal area_resized(size_up, pressed)

signal add_dice(type, amount)
signal execute_command(parsed_command)
signal clear_dice(type)
signal roll_all
signal roll_invalid
signal lock_valid


func _ready() -> void:
	SettingsData.listen(self, "_on_dice_setting_changed")
	for type in dice_types:
		var select := preload("res://Interface/DiceSelect.tscn").instance()
		select.name = type
		select.type = type
		# warning-ignore:return_value_discarded
		select.connect("add_dice", self, "_on_DiceSelectAdd_button_down")
		# warning-ignore:return_value_discarded
		select.connect("remove_dice", self, "_on_DiceSelectRemove_button_down")
		$Layout/Interactions/DiceSelects.add_child(select)
	apply_settings_recursive(self)
	SettingsData.connect("settings_saved", self, "toast_message", ["Saved!", 0, 2])

	$DiceCommands.connect("toast_error", self, "toast_message")


func _unhandled_input(event: InputEvent) -> void:
	if SettingsData.get_setting("use_commands"):
		return
	var key_event := event as InputEventKey
	if key_event and key_event.is_action_pressed("number_shortcut"): # 1-9
		var type_index := clamp(int(key_event.as_text()), 0, dice_types.size())
		var type: String = dice_types[type_index - 1] # start at 0
		self.selected_type = type
		emit_signal("add_dice", selected_type)


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
	load("res://Interface/Icons/%s.png" % type)


func _on_DiceSelectAdd_button_down(type: String, amount: int) -> void:
	self.selected_type = type
	emit_signal("add_dice", type, amount)


func _on_dice_setting_changed(setting: String) -> void:
	handle_interface_setting(setting)


func apply_settings() -> void:
	for setting in SettingsData.settings:
		handle_interface_setting(setting)


func handle_interface_setting(setting: String) -> void:
	if "show_input_d" in setting:
		var dice_select_name = setting.trim_prefix("show_input_") # d4, d6, d8 ...
		var select = $Layout/Interactions/DiceSelects.get_node(dice_select_name)
		select.visible = SettingsData.get_setting(setting)

	if setting == "use_commands":
		emit_signal("clear_dice", "")
		var is_dice_commands_visible: bool = SettingsData.get_setting(setting)
		$DiceCommands.visible = is_dice_commands_visible
		$Layout/Interactions/Buttons/Buttons/RollCommand.visible = is_dice_commands_visible
		$Layout/Interactions/DiceSelects.visible = not is_dice_commands_visible
		$Layout/Interactions/Buttons/Buttons/AddDie.visible = not is_dice_commands_visible


func _on_DiceSelectRemove_button_down(type: String) -> void:
	emit_signal("clear_dice", type)


func _on_DiceCommands_execute_command(parsed_command: Dictionary) -> void:
	emit_signal("execute_command", parsed_command)


func _on_AddDie_button_down() -> void:
	emit_signal("add_dice", selected_type)


func _on_RollCommand_pressed() -> void:
	($DiceCommands as DiceCommands).try_execute_command()


func _on_ClearDice_button_down() -> void:
	emit_signal("clear_dice", "")


func _on_Roll_button_down() -> void:
	emit_signal("roll_all")


func _on_RollInvalidDice_button_down() -> void:
	emit_signal("roll_invalid")


func _on_LockValidDice_button_down() -> void:
	emit_signal("lock_valid")


func _on_Settings_pressed() -> void:
	$Settings.visible = not $Settings.visible


func _on_Help_pressed() -> void:
	$Help.visible = not $Help.visible


func _on_SizeUp_button_down() -> void:
	emit_signal("area_resized", true, true)


func _on_SizeUp_button_up() -> void:
	emit_signal("area_resized", true, false)


func _on_SizeDown_button_down() -> void:
	emit_signal("area_resized", false, true)


func _on_SizeDown_button_up() -> void:
	emit_signal("area_resized", false, false)


func _on_ZoomIn_button_down() -> void:
	emit_signal("camera_zoomed", true, true)


func _on_ZoomIn_button_up() -> void:
	emit_signal("camera_zoomed", true, false)


func _on_ZoomOut_button_down() -> void:
	emit_signal("camera_zoomed", false, true)


func _on_ZoomOut_button_up() -> void:
	emit_signal("camera_zoomed", false, false)

