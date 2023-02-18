extends Resource
class_name DiceCommandGroupRule

const dice_types := [4, 6, 8, 10, 12, 20]

var id := ""								# group_id
var dice_string := ""
var error := false
var messages := []						# msg
var compound := []
var explode := []
var reroll_once := []
var reroll := []
var drop_dice := 0
var drop_lowest := true
var dice_type_side_count: int				# dice_side
var dice_count := 0
var dice_instances := []


func _init(_dice_string: String, _id: String) -> void:
	id = _id
	dice_string = _dice_string
	var parsed = SingleDiceCommandUtils.base_dice_parser(dice_string, id)


	var valid_tokens = "[dksr!]"
	dice_string = dice_string.to_lower()


	# get the dice count or default to 1 if we just start with d.
	var result = StringManipulation.str_extract(dice_string, "^[0-9]*?(?=d)")
	assert_condition(not result == null, "Malformed dice string")
	if result == "":
		dice_count = 1
	elif result == null:
		return
	elif result.is_valid_integer():
		dice_count = int(result)

	# tokenize the rest of the rolling rules. a token character, followed by the
	# next valid token character or end of string. while processing, remove
	# all processed tokens and check for anything leftower at the end

	var tokens = StringManipulation.str_extract_all(dice_string,
	valid_tokens + ".*?((?=" + valid_tokens + ")|$)")


	var dice_side = StringManipulation.str_extract(tokens[0], "(?<=d)[0-9]+")
	assert_condition(dice_side != null, "Malformed dice string: Unable to detect dice sides")
	assert_condition(int(dice_side) in dice_types, "Invalid dice type.\nValid types: " + String(dice_types))
	if dice_side!=null:
		dice_type_side_count = int(dice_side)
	else:
		return
	# remove dice side token to make sure it"s not confused with the drop rule
	tokens.remove(0)


	# check for drop rules, there can only be one
	var drop_rules = StringManipulation.strs_detect(tokens, "^(d|k)(h|l)?[0-9]+$")
	assert_condition(drop_rules.size() <= 1, "Malformed dice string: Can't include more than one drop rule")
	if drop_rules.size() == 0:
		drop_dice = 0
		drop_lowest = true
	else:
		var drop_count = StringManipulation.str_extract(tokens[drop_rules[0]], "[0-9]+$")
#		assert_condition(drop_count != null, "Malformed dice string: No drop count provided") # never triggered due to * in regex
		var drop_rule = tokens[drop_rules[0]]
		match drop_rule.substr(0, 1):
			"d":
				drop_dice = int(drop_count)
			"k":
				drop_dice = int(dice_count)-int(drop_count)
		drop_lowest = !(StringManipulation.str_detect(drop_rule, "dh") or StringManipulation.str_detect(drop_rule, "kl"))
		tokens.remove(drop_rules[0])

	# reroll rules
	var reroll_rules = StringManipulation.strs_detect(tokens, "r(?!o)")
	for i in reroll_rules:
		reroll.append_array(DiceCommandUtilities.range_determine(tokens[i], dice_type_side_count))
	var dicePossibilities = range(1, dice_type_side_count + 1)
	# dice_error(!ArrayLogic.all(ArrayLogic.array_in_array(dicePossibilities, reroll)), "Malformed dice string: rerolling all results", rolling_rules)

	# remove reroll rules
	reroll_rules.invert()
	for i in reroll_rules:
		tokens.remove(i)

	# reroll once
	reroll_rules = StringManipulation.strs_detect(tokens, "ro")
	for i in reroll_rules:
		var to_reroll = DiceCommandUtilities.range_determine(tokens[i], dice_type_side_count)
		assert_condition(ArrayLogic.which_in_array(to_reroll, reroll_once).size() == 0, "Malformed dice string: can't reroll the same number once more than once.")
		reroll_once.append_array(DiceCommandUtilities.range_determine(tokens[i], dice_type_side_count))

	reroll_rules.invert()
	for i in reroll_rules:
		tokens.remove(i)


	# new explode rules
	var explode_rules := StringManipulation.strs_detect(tokens, "!")
	var compound_flag: bool = false
	for i in explode_rules:
		if not i == INF:
			if tokens[i] == "!" and i+1 in explode_rules:
				compound_flag = true
			elif not compound_flag:
				explode.append_array(DiceCommandUtilities.range_determine(tokens[i], dice_type_side_count, dice_type_side_count))
			elif compound_flag:
				compound_flag = false
				compound.append_array(DiceCommandUtilities.range_determine(tokens[i], dice_type_side_count, dice_type_side_count))
	explode_rules.invert()
	for i in explode_rules:
		tokens.remove(i)

	assert_condition(tokens.size()==0, "Malformed dice string: Unprocessed tokens")
	var possible_dice = range(1, dice_type_side_count + 1)
	possible_dice = ArrayLogic.array_subset(
		possible_dice, ArrayLogic.which(
			ArrayLogic.array_not(
				ArrayLogic.array_in_array(possible_dice, reroll)
			)
		)
	)
	assert_condition(possible_dice.size()>0, "Invalid dice: No possible results")
	assert_condition(not (ArrayLogic.all(ArrayLogic.array_in_array(possible_dice, explode)) and explode.size()>0), "Invalid dice: Can't explode every result")
	assert_condition(not (ArrayLogic.all(ArrayLogic.array_in_array(possible_dice, compound)) and compound.size()>0), "Invalid dice: Can't compound every result")
	assert_condition(ArrayLogic.which_in_array(explode, compound).size()==0, "Invalid dice: Can't explode what you compound.")
	assert_condition(dice_count > 0, "Invalid dice: Can't roll less than one die")
	assert_condition(dice_count <= 0 or drop_dice < dice_count, "Invalid dice: Can't drop all the dice you have")

	assert_condition(not (explode.size()>0 and compound.size()>0), "Invalid dice: Can't explode and compound with the same dice")



# add error information to the output if something goes wrong.
func assert_condition(condition: bool, message: String) -> void:
	if not condition:
		error = true
		messages.append(message)


func all_dice_settled() -> bool:
	for die in dice_instances:
		if not (die as Die).has_settled():
			return false
	return true


func get_reroll_dice() -> Array:
	var reroll_dice := []
	for die in dice_instances:
		if (die as Die).get_rolled_side() in reroll:
			reroll_dice.append(die)

	return reroll_dice


#	func get_highest_rolled_die(group_id: String) -> Die:
#
#		return null
#
#
#	func get_rolled_dice_above_value(group_id: String, value: int) -> PoolIntArray:
#		return PoolIntArray([])
#
#
#	func get_rolled_dice_below_value(group_id: String, value: int) -> PoolIntArray:
#		return PoolIntArray([])


func _to_string() -> String:
	var props := get_property_list()
	var self_as_dict := {}
	for prop in props:
		if prop.usage == 8192: # custom property
			var value = get(prop.name)

			if value is Array and value.size() > 0 and value[0] is Object:
				self_as_dict[prop.name] = str(value)
			else:
				self_as_dict[prop.name] = value

	return var2str(self_as_dict)

