extends Control


onready var type_data_container := $Margin/Container
onready var header_label: Label = $Margin/Container/TotalStatistic/Genral/Grid/Sum
onready var header_icon: TextureRect = $Margin/Container/TotalStatistic/Genral/Grid/TypeContainer/TypeIcon


const LETTERS := "abcdefghijklmnopqrstuvwxyz"
const NUMBERS := "1234567890"
const OPERATORS := "+-*/"
const GROUP_START := "("
const GROUP_END := ")"


var die_type_stats := {}

export var dice_command := ""

func _ready() -> void:
	header_icon.texture = preload("res://Interface/Icons/commands.png")


func _on_RefreshRate_timeout() -> void:
	var sum := DiceData.get_sum()
	var float_precision := 0 if fmod(sum, 1.0) == 0 else 2

	header_label.text = "%.*f" % [ float_precision, sum ]
	if not DiceData.dice_command:
		return

	# since a command won't ever change the amount of dice,
	# we can create the structure once and then just update it
	if die_type_stats.empty():
		initialize_tree_structure(DiceData.dice_command.expression_component_string)
		return

	update_dice_statistics()


func update_dice_statistics() -> void:
	for type in DiceData.type_data:
		var type_data: DieTypeData = DiceData.type_data[type]
		var type_stat: DieTypeStatistic = die_type_stats[type]
		type_stat.die_type_data = type_data
		type_stat.update_labels()


func initialize_tree_structure(components_string: String) -> void:
	var container_stack := [type_data_container]
	var current_parent := type_data_container

	for component in components_string:
		if component in OPERATORS:
			current_parent.add_child(create_operator(component))

		elif component in LETTERS:
			var stat := create_type_stat(component)
			current_parent.add_child(stat)
			die_type_stats["die-%s" % component] = stat

		elif component in NUMBERS:
			current_parent.add_child(create_constant_number(component))

		elif component == GROUP_START:
			var bracket := create_bracket()
			current_parent.add_child(bracket)
			current_parent = bracket
			container_stack.append(current_parent)

		elif component == GROUP_END:
			container_stack.pop_back()
			current_parent = container_stack.back()


func create_type_stat(group_name: String) -> DieTypeStatistic:
	var type_stat: DieTypeStatistic = preload('res://Interface/DieTypeStatistic.tscn').instance()
	var type := "die-%s" % group_name
	if not DiceData.type_data.has(type):
		push_error("DiceData.type_data has no data of type %s" % type)
		return type_stat
	var type_data: DieTypeData = DiceData.type_data[type]
	type_stat.die_type_data = type_data
	type_stat.boxed_style = not not type_data.group_id
	type_stat.name = type
	return type_stat


func create_operator(text: String) -> Node:
	var operator: Label = preload("res://Interface/CommandStatisticOperator.tscn").instance()
	operator.text = text
	return operator


func create_constant_number(number_text: String) -> Node:
	var constant := preload("res://Interface/CommandStatisticNumber.tscn").instance()
	constant.get_node("Label").text = number_text
	return constant


func create_bracket() -> Node:
	return preload("res://Interface/CommandStatisticBracket.tscn").instance()


#	var is_type_data_grouped: bool = false
#
#	for type in DiceData.type_data:
#		if "-" in type:
#			is_type_data_grouped = true
#
#		var type_data: DieTypeData = DiceData.type_data[type]
#		var type_stat: DieTypeStatistic
#
#		if die_type_stats.has(type):
#			type_stat = die_type_stats[type]
#			if type_data.instances_rolled.empty():
#				type_stat.queue_free()
#				die_type_stats.erase(type)
#				DiceData.type_data.erase(type)
#				return
#			type_stat.die_type_data = type_data
#			type_stat.update_labels()
#		elif is_type_data_grouped:
#			type_stat = preload('res://Interface/DieTypeStatistic.tscn').instance()
#			type_stat.die_type_data = type_data
#			type_stat.boxed_style = not not type_data.group_id
#			type_stat.name = type
#			die_type_stats[type] = type_stat
#			type_data_container.add_child(type_stat)
#
#	for type in die_type_stats:
#		if not type in DiceData.type_data.keys():
#			die_type_stats[type].queue_free()
#
#	if not is_type_data_grouped:
#		sort_dice_statistics()


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

