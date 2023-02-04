extends Spatial

export var dice_type_strings: PoolStringArray
export var dice_type_scenes: Dictionary

var max_addable : Dictionary

var dice_locked := false


func _ready() -> void:
	SettingsData.listen(self, "_on_settings_changed")


func add_dice(type: String, amount: int, group_id: String = "") -> void:
	if max_addable.has(type):
		max_addable[type] += amount
	else:
		max_addable[type] = amount
	add_multiple_dice(type, group_id)


func add_multiple_dice(type: String, group_id: String = "") -> void:
	if not max_addable or not max_addable.has(type):
		return

	while max_addable[type] > 0:
		max_addable[type] -= 1
		add_die(type, group_id)
		yield(get_tree().create_timer(.0003), 'timeout')


func add_die(type: String, group_id: String = "") -> void:
	assert(dice_type_scenes.has(type), "invalid dice type: " + str(type))

	var new_die: Die = (dice_type_scenes[type] as PackedScene).instance()
	self.add_child(new_die)
	new_die.group_id = group_id
	new_die.gravity_scale = SettingsData.get_setting("gravity", 4)

	# warning-ignore:return_value_discarded
	new_die.connect("die_respawn", self, "add_die")
	# warning-ignore:return_value_discarded
	new_die.connect("die_died", $"/root/DiceData", "_on_die_died")
	# warning-ignore:return_value_discarded
	new_die.connect("die_rolled", $"/root/DiceData", "_on_die_rolled")
	randomize_throw(new_die)


func clear_dice(type: String = "") -> void:
	if type:
		max_addable[type] = 0
	else:
		for type in max_addable:
			max_addable[type] = 0

	for die in self.get_children():
		if not type or type == die.type:
			die.die()


func get_lowest_rolled_die(group_id: String) -> int:
	var type_data := DiceData.get_type_data_by_group_id(group_id)
	if not type_data:
		return 0

	type_data.sides

	return 0


func get_highest_rolled_die(group_id: String) -> int:

	return 0


func get_rolled_dice_above_value(group_id: String, value: int) -> PoolIntArray:
	return PoolIntArray([])


func get_rolled_dice_below_value(group_id: String, value: int) -> PoolIntArray:
	return PoolIntArray([])


func _on_Interface_add_dice(type: String, amount: int = 1) -> void:
	add_dice(type, amount)


func _on_Interface_execute_command(parsed_command: Dictionary) -> void:
	clear_dice()
	DiceData.command_expression = parsed_command.dice_expression
	DiceData.expression_components = parsed_command.expression_components

	for dice_group in parsed_command.rules_array:
		add_dice("d%s" % dice_group.dice_side, dice_group.dice_count, dice_group.group_id)
		yield(get_tree().create_timer(1), "timeout")


func _on_Interface_clear_dice(type: String) -> void:
	clear_dice(type)


func _on_Interface_roll_all() -> void:
	for die in self.get_children():
		roll(die)


func _on_Interface_roll_invalid() -> void:
	for die in self.get_children():
		if die.invalid == true:
			roll(die)


func _on_Interface_lock_valid() -> void:
	if not dice_locked:
		for die in self.get_children():
			die = die as Die
			die.get_rolled_side()
			if die.invalid == false:
				die.set_locked(true)
		dice_locked = true
	else:
		for die in self.get_children():
			die.set_locked(false)
		dice_locked = false


func _on_settings_changed(setting: String) -> void:
	match setting:
		"gravity":
			for die in get_children():
				die = die as Die
				die.gravity_scale = SettingsData.get_setting(setting)
		"use_commands":
			if not SettingsData.get_setting(setting):
				DiceData.command_expression = null
				DiceData.expression_components = []


func randomize_throw(die: Die) -> void:
	var area_size_x: int = $"/root/main/Box/Floor/CollisionShape".get_shape().extents.x * $"/root/main".global_area_scale
	var area_size_z: int = $"/root/main/Box/Floor/CollisionShape".get_shape().extents.z * $"/root/main".global_area_scale
	var min_throw_height := int(ceil($"/root/main".global_area_scale*10))
	die.global_transform.origin = Vector3(
		random_value_in_range(0, int(area_size_x/2.0), true),
		random_value_in_range(min_throw_height, min_throw_height + 3),
		random_value_in_range(0, int(area_size_z/2.0), true)
	)
	die.linear_velocity = Vector3(
		random_value_in_range(2, 3, true),
		0,
		random_value_in_range(2, 3, true)
	)
	die.angular_velocity = Vector3(
		random_value_in_range(5, 10, true),
		random_value_in_range(5, 10, true),
		random_value_in_range(5, 10, true)
	)


func roll(die: Die) -> void:
	var max_up_velocity := int(ceil($"/root/main".global_area_scale*5) * 5)
	die.linear_velocity = Vector3(
			random_value_in_range(1, 3, true),
			random_value_in_range(10, max_up_velocity),
			random_value_in_range(1, 3, true)
	)
	die.angular_velocity = Vector3(
		random_value_in_range(5, 10, true),
		random_value_in_range(5, 10, true),
		random_value_in_range(5, 10, true)
	)


func random_value_in_range(minimum: int, maximum: int, rand_sign: bool = false) -> int:
	var value = (randi() % (maximum +1)) + minimum
	if rand_sign and randi() % 2:
		value *= -1
	return value


