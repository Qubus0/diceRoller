extends Control


onready var type_data_container := $Margin/Container
onready var header_label: Label = $Margin/Container/TotalStatistic/Genral/Grid/Sum
onready var header_icon: TextureRect = $Margin/Container/TotalStatistic/Genral/Grid/TypeContainer/TypeIcon

var die_type_stats := {}

export var dice_command := ""

func _ready() -> void:
	SettingsData.listen(self, "handle_statistics_setting")


func apply_settings():
	for setting in SettingsData.settings:
		handle_statistics_setting(setting)


func handle_statistics_setting(setting: String):
	if setting == "use_commands":
		if SettingsData.get_setting(setting):
			header_icon.texture = preload("res://Interface/Icons/commands.png")
			$Margin/Container/TotalStatistic/HSeparator.hide()
		else:
			header_icon.texture = preload("res://Interface/Icons/sum.png")
			$Margin/Container/TotalStatistic/HSeparator.show()


func _on_RefreshRate_timeout() -> void:
	var sum := DiceData.get_sum()
	var float_precision := 0 if fmod(sum, 1.0) == 0 else 2

	header_label.text = "%.*f" % [ float_precision, sum ]
	update_dice_statistics()


func update_dice_statistics() -> void:
	var is_type_data_grouped: bool = false

	for type in DiceData.type_data:
		if "-" in type:
			is_type_data_grouped = true

		var type_data: DieTypeData = DiceData.type_data[type]
		var type_stat: DieTypeStatistic

		if die_type_stats.has(type):
			type_stat = die_type_stats[type]
			if type_data.instances_rolled.empty():
				type_stat.queue_free()
				die_type_stats.erase(type)
				DiceData.type_data.erase(type)
				return
			type_stat.die_type_data = type_data
			type_stat.update_labels()
		elif is_type_data_grouped:
			type_stat = preload('res://Interface/DieTypeStatistic.tscn').instance()
			type_stat.die_type_data = type_data
			type_stat.boxed_style = not not type_data.group_id
			type_stat.name = type
			die_type_stats[type] = type_stat
			type_data_container.add_child(type_stat)

	for type in die_type_stats:
		if not type in DiceData.type_data.keys():
			die_type_stats[type].queue_free()

	if not is_type_data_grouped:
		sort_dice_statistics()


func sort_dice_statistics() -> void:
	# offset total stats node, so it stays above the others
	var offset := 1

	var sorted_types: Array = DiceData.type_data.keys()
	sorted_types.sort_custom(self, "sort_dice_types_ascending")

	for type_index in sorted_types.size():
		var type_stat: Control = type_data_container.get_node(sorted_types[type_index])
		type_data_container.move_child(type_stat, type_index + offset)


func sort_dice_types_ascending(type_a: String, type_b: String) -> bool:
	# every type begins with 'd' (int ignores all letters)
	return int(type_a) < int(type_b)

