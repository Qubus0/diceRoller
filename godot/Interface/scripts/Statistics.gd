extends Control

onready var type_data_container := $Margin/Container


func _on_RefreshRate_timeout() -> void:
	$Margin/Container/TotalStatistic/Genral/Grid/Sum.text = str(DiceData.get_sum())
	update_dice_statistics()


func update_dice_statistics() -> void:
	for type in DiceData.type_data:
		var type_data: DieTypeData = DiceData.type_data[type]
		var type_stat: DieTypeStatistic

		if type_data_container.has_node(type):
			type_stat = type_data_container.get_node(type)
			if type_data.instances_rolled.empty():
				type_stat.queue_free()
				#warning-ignore: return_value_discarded
				DiceData.type_data.erase(type)
				return
			type_stat.die_type_data = type_data
			type_stat.update_labels()
		else:
			type_stat = preload('res://Interface/DieTypeStatistic.tscn').instance()
			type_stat.die_type_data = type_data
			type_stat.name = type_data.type
			type_data_container.add_child(type_stat)


	for dice_stat in type_data_container.get_children():
		if not dice_stat is DieTypeStatistic:
			continue
		if not dice_stat.name in DiceData.type_data.keys():
			dice_stat.queue_free()

	sort_dice_statistics()


func sort_dice_statistics() -> void:
	# offset the timer and total stats nodes, so they stay above the others
	var offset := 2

	var sorted_types: Array = DiceData.type_data.keys()
	sorted_types.sort_custom(self, "sort_dice_types_ascending")

	for type_index in len(sorted_types):
		var type_stat: Control = type_data_container.get_node(sorted_types[type_index])
		type_data_container.move_child(type_stat, type_index + offset)


func sort_dice_types_ascending(type_a: String, type_b: String) -> bool:
	# every type begins with 'd' (int ignores all letters)
	return int(type_a) < int(type_b)

