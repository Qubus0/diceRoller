extends Node

class_name DieTypeData

var type: String

var sides := []			# [1, 2, 3 ...]   needed so things stay sorted
var side_totals := {}	# { 1: [412, 443, ...(instace_id)], 2: [...], ...}
var instances_rolled := {}	# {412: 3, 413: 5, instance_id: rolled_side}


func _init(die: Die) -> void:
	type = die.type

	sides = die.sides.keys()
	sides.append(0) # invalid dice 'roll' 0
	sides.sort()

	for side in sides:
		side_totals[side] = []


func get_total() -> int:
	return instances_rolled.size()


func get_sum() -> int:
	var sum := 0
	for side in sides:
		sum += side_totals[side].size() * side
	return sum


func has_instance(instance_id: int) -> bool:
	return instances_rolled.has(instance_id)


func remove_from_side_totals(instance_id: int) -> void:
	var rolled_side: int = instances_rolled[instance_id]
	side_totals[rolled_side].erase(instance_id)


func add_to_dice_totals(instance_id: int, rolled_side: int) -> void:
	instances_rolled[instance_id] = rolled_side

