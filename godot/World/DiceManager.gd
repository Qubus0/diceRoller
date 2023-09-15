extends Spatial

signal added_dice_group

const dice_group_prefix := "die-"

export var dice_type_strings: PoolStringArray
export var dice_type_scenes: Dictionary

var max_addable : Dictionary

var dice_locked := false


func _ready() -> void:
	SettingsData.listen(self, "_on_settings_changed")


func _process(delta: float) -> void:
	# no command, don't interfere with freerolls
	if not DiceData.dice_command:
		return
	# don't do anything if not all results are in
	if not DiceData.dice_command.all_groups_settled():
		return
	printt("stage:", DiceData.dice_command.execution_stage)

	# stop other moving dice from changing results
	for die in get_children():
		(die as Die).locked = true

	match DiceData.dice_command.execution_stage:
		DiceCommand.stages.REROLL:
			var did_reroll := false
			for group in DiceData.dice_command.dice_groups:
				var dice_group := (group as DiceCommandGroupRule)

				for die in dice_group.get_reroll_dice():
					die.locked = false
					reroll_consecutive(die, 3)
					did_reroll = true

			if not did_reroll:
				DiceData.dice_command.execution_stage += 1




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
	emit_signal("added_dice_group")


func add_die(type: String, group_id: String = "") -> void:
	if not dice_type_scenes.has(type):
		assert(false, "invalid dice type: " + str(type))
		return

	var new_die: Die = (dice_type_scenes[type] as PackedScene).instance()
	self.add_child(new_die)
	new_die.group_id = group_id
	new_die.add_to_group(group_id)
	new_die.gravity_scale = SettingsData.get_setting("gravity", 4)

	# warning-ignore:return_value_discarded
	new_die.connect("die_respawn", self, "add_die")
	# warning-ignore:return_value_discarded
	new_die.connect("die_died", $"/root/DiceData", "_on_die_died")
	# warning-ignore:return_value_discarded
	new_die.connect("die_rolled", $"/root/DiceData", "_on_die_rolled")
	randomize_throw(new_die)


func clear_dice(type: String = "") -> void:
	DiceData.dice_command = null
	if type:
		max_addable[type] = 0
	else:
		for type in max_addable:
			max_addable[type] = 0

	for die in self.get_children():
		if not type or type == die.type:
			die.die()


func _on_Interface_add_dice(type: String, amount: int = 1) -> void:
	add_dice(type, amount)


func _on_Interface_execute_command(parsed_command: DiceCommand) -> void:
	clear_dice()

	for dice_group in parsed_command.dice_groups:
		var group := dice_group as DiceCommandGroupRule
		var group_id := dice_group_prefix + str(group.id)
		add_dice("d%s" % group.dice_type_side_count, group.dice_count, group_id)
		yield(self, "added_dice_group")
		group.dice_instances = get_tree().get_nodes_in_group(group_id)

	parsed_command.execution_stage += 1
	DiceData.dice_command = parsed_command
	print()
	print(JSON.print(str2var(str(parsed_command)), "  "))
	print()



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
				DiceData.dice_command = null


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


func reroll_consecutive(die: Die, rerolls := 1, delay := 0.2):
	for roll in rerolls:
		roll(die)
		yield(get_tree().create_timer(delay), "timeout")


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


