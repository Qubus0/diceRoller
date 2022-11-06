extends Spatial

export var dice_type_strings: PoolStringArray
export var dice_type_scenes: Dictionary

var dice_locked := false


func _ready() -> void:
	SettingsData.listen(self, "_on_settings_changed")


func _on_Interface_add_die(type: String) -> void:
	add_die(type)


func add_die(type: String) -> void:
	assert(dice_type_scenes.has(type), "invalid dice type: " + str(type))

	var new_die: Die = (dice_type_scenes[type] as PackedScene).instance()
	self.add_child(new_die)
	new_die.gravity_scale = SettingsData.get_setting("gravity", 4)

	# warning-ignore:return_value_discarded
	new_die.connect("die_respawn", self, "add_die")
	# warning-ignore:return_value_discarded
	new_die.connect("die_died", $"/root/DiceData", "_on_die_died")
	# warning-ignore:return_value_discarded
	new_die.connect("die_rolled", $"/root/DiceData", "_on_die_rolled")
	randomize_throw(new_die)


func _on_Interface_clear_dice(type: String) -> void:
	for die in self.get_children():
		if not type or type == die.type:
			die.die()


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


func _on_settings_changed(setting: String, value) -> void:
	if setting == "gravity":
		for die in get_children():
			die = die as Die
			die.gravity_scale = value


func randomize_throw(die: Die) -> void:
	var area_size_x: int = $"/root/main/Box/Floor/CollisionShape".get_shape().extents.x * $"/root/main".global_area_scale
	var area_size_z: int = $"/root/main/Box/Floor/CollisionShape".get_shape().extents.z * $"/root/main".global_area_scale
	var min_throw_height := ceil($"/root/main".global_area_scale*10)
	die.global_transform.origin = Vector3(
		random_value_in_range(0, area_size_x/2, true),
		random_value_in_range(min_throw_height, min_throw_height + 3),
		random_value_in_range(0, area_size_z/2, true)
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
	var max_up_velocity := ceil($"/root/main".global_area_scale*5) * 5
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

