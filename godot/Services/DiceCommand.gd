extends Resource
class_name DiceCommand

enum stages {
	ADD,
	REROLL,
}

var execution_stage := 0

var error := false
var messages := []							# msg
var expression := Expression.new() 			# dice_expression
var expression_component_string := "" 		# expression_string
var expression_string := "" 					# full_string
var expression_components: PoolStringArray	# expression_components
var dice_groups := [] 						# rules_array


func _init(_expression_string: String) -> void:
	expression_string = _expression_string
	var dice_regex = "[0-9]+d[0-9]+[dksro!<>0-9lh]*"

	# example expression: 2d20*3+3d6r<2
	# only the dice part of the expression: [2d20, 3d6r<2]
	var expression_dice_components := StringManipulation.str_extract_all(expression_string, dice_regex)
	# only the operator part: [, *3+, ]
	var expression_operator_compoments := StringManipulation.str_split(expression_string, dice_regex)

	# replace all dice components with letters: z*3+a
	for i in expression_operator_compoments.size():
		expression_component_string += expression_operator_compoments[i]
		if i < expression_dice_components.size():
			expression_components.append(DiceCommandUtilities.int_to_letter(i))
			expression_component_string += expression_components[i]

	# parse each dice componenent into DiceCommandGroupRules
	# func parse_dice_components() -> DiceCommandGroupRules:
	for component_index in expression_dice_components.size():
		var dice_string := expression_dice_components[component_index]
		var group_id := DiceCommandUtilities.int_to_letter(component_index)
		var group_rule := DiceCommandGroupRule.new(dice_string, group_id)

		if group_rule.error:
			error = true
			messages.append_array(group_rule.messages)

		dice_groups.append(group_rule)

	var expression_error := get_expression_error(expression)
	if not expression_error == "":
		error = true
		messages.append(expression_error)


func get_expression_error(_expression: Expression) -> String:
	var parse_error = _expression.parse(expression_component_string, expression_components)
	if not parse_error == OK:
		return "Input roll expression could not be parsed"

	# test execution to see if it's valid
	var test_out = []
	for _i in expression_components.size():
		test_out.append(1.0)

	if test_out.size() <= 0:
		return "Input does not contain a valid roll expression"

	_expression.execute(test_out, null, false)
	if _expression.has_execute_failed() or not _expression.get_error_text() == "":
			return "Expression fails to execute"

	return ""


func all_groups_settled() -> bool:
	for group in dice_groups:
		if not (group as DiceCommandGroupRule).all_dice_settled():
			return false
	return true


func _to_string() -> String:
	var props := get_property_list()
	var self_as_dict := {}
	for prop in props:
		if prop.usage == 8192: # custom property
			var value = get(prop.name)
			# array of custom resources
			if value is Array and value.size() > 0 and value[0] is Object:
				self_as_dict[prop.name] = str2var(str(value))
				continue

			self_as_dict[prop.name] = value

	return var2str(self_as_dict)


