extends Node

var type_data := {} setget update_die_types 	# DieTypeData[]


func _on_die_rolled(type: String, rolled_side: int, instance_id: int) -> void:
	if not type_data.has(type):
		type_data[type] = DieTypeData.new(instance_from_id(instance_id)) as DieTypeData

	# keep track of all instances and their rolled sides (this also gives us the total)
	# if an instance is in there already, it also is in the sides array
	# from instances, we get the side, in the side array, remove that id
	if type_data[type].has_instance(instance_id):
		type_data[type].remove_from_side_totals(instance_id)

	type_data[type].add_to_dice_totals(instance_id, rolled_side)
	(type_data[type].side_totals[rolled_side] as Array).append(instance_id)


func _on_die_died(type: String, instance_id: int) -> void:
	if not type_data.has(type):
		return
	if type_data[type].has_instance(instance_id):
		type_data[type].remove_from_side_totals(instance_id)
	type_data[type].instances_rolled.erase(instance_id)


func get_total() -> int:
	var total := 0
	for type in type_data:
		total += (type_data[type] as DieTypeData).get_total()
	return total


func get_sum() -> int:
	var sum := 0
	for type in type_data:
		sum += (type_data[type] as DieTypeData).get_sum()
	return sum


func update_die_types(new_types: Dictionary) -> void:
	for new_type in new_types:
		type_data[new_type] = new_types[new_type]


