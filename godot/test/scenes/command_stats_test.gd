extends Control

#var commands := {
#	"(2d20+4)*3+(3d6r<2+2)": {
#		"z": DieTypeData.new(MockDie.new(4))
#	},
#	"2d20*3+3d6r<2": [],
#}

var command := "(2d20+4)*3+(3d6r<2+2)"


func _ready() -> void:
	DiceData.dice_command = DiceCommand.new(command)
	print(DiceData.dice_command.expression_component_string)

	var d20s := [
		MockDie.new("d20", 4, "z"),
		MockDie.new("d20", 8, "z"),
	]
	var d20_data := DieTypeData.new(d20s.front())
	for die_index in d20s.size():
		var side: int = d20s[die_index].side
		if not d20_data.side_totals.has(side):
			d20_data.side_totals[side] = []
		d20_data.side_totals[side].append(die_index)
		d20_data.instances_rolled[die_index] = side
	d20_data.instances_rolled
	DiceData.type_data["die-z"] = d20_data

	var d6s := [
		MockDie.new("d6", 3, "a"),
		MockDie.new("d6", 3, "a"),
		MockDie.new("d6", 6, "a"),
	]
	var d6_data := DieTypeData.new(d6s.front())
	for die_index in d6s.size():
		var side: int = d6s[die_index].side
		if not d6_data.side_totals.has(side):
			d6_data.side_totals[side] = []
		d6_data.side_totals[side].append(die_index)
		d6_data.instances_rolled[die_index] = side
	d6_data.instances_rolled
	DiceData.type_data["die-a"] = d6_data

	# Test the stat updating. Doesn't remove the old side, but that doesn't matter
	for i in 30:
		yield(get_tree().create_timer(1), "timeout")
		var side := (randi() % 6) + 1
		if not d6_data.side_totals.has(side):
			d6_data.side_totals[side] = []
		d6_data.side_totals[side].append(0)
		d6_data.instances_rolled[0] = side



