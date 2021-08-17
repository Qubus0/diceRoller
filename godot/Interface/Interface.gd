extends Control

var max_dice = 30
var selected_type = 'd6'

signal max_dice
signal add_max
signal add_die
signal clear
signal roll
signal roll_invalid
signal lock_valid
signal scale_scene
signal zoom_camera

onready var counters = {
	'd6': $d6Counter,
	'd20': $d20Counter,
	}

onready var labels = {
	'd6': $d6Counter/Label,
	'd20': $d20Counter/Label,
	}

var dice = {
#	'd4': {},
	'd6': {},
#	'd8': {},
#	'd10': {},
#	'd12': {},
	'd20': {},
	}

func _ready():
	for counter in counters:
		counters[counter].connect('max_dice', self, 'max_changed')
	clear_counters()
	
func max_changed(type, max_value):
	selected_type = type
	emit_signal('max_dice', type, max_value)
	
func clear_labels():
	for label in labels:
		labels[label].text = ''
	
func clear_counters():
	for key in dice.keys():
		var die_type = key
		key.erase(0, 1)		# removes the d from 'd20'
		for side in range(key):
			dice[die_type][side+1] = []
		dice[die_type]['?'] = []


func update_all_counters(dice_type, current_side, dice_id):
	var die = dice[dice_type]
	for side in die.keys():
		die[side].erase(dice_id)
	die[current_side].append(dice_id)
	update_counter(dice_type)

func update_counter(dice_type):
	labels[dice_type].text = ''
	var diceSides = dice[dice_type]
	var labelRows = []
	var sum = 0
	for side in diceSides:
		if not diceSides[side] == [] and not str(side) == '?':
			labelRows.append('[ ' + str(side) + ' ]  ' + str(diceSides[side].size()))
			sum += side * diceSides[side].size()
	if not diceSides['?'] == []:	# put unknown dice side last
		labelRows.append('[ ? ]  ' + str(diceSides['?'].size()))
	labelRows.append('∑  ' + str(sum))
	labels[dice_type].text = PoolStringArray(labelRows).join('\n')


func _on_AddMaxDice_button_down():
	clear_counters()
	emit_signal('add_max')
	
func _on_AddDie_button_down() -> void:
	emit_signal('add_die', selected_type)
	
func _on_ClearDice_button_down() -> void:
	clear_counters()
	emit_signal('clear')

func _on_Roll_button_down() -> void:
	emit_signal('roll')
	
func _on_RollInvalidDice_button_down() -> void:
	emit_signal('roll_invalid')

func _on_LockValidDice_button_down() -> void:
	emit_signal('lock_valid')

func _on_AreaScale_value_changed(value) -> void:
	emit_signal('scale_scene', value)

func _on_CameraZoom_value_changed(value: float) -> void:
	emit_signal('zoom_camera', value)
	
func _on_AreaScale_CameraZoom(value: float) -> void:
	$CameraZoom.value = value


