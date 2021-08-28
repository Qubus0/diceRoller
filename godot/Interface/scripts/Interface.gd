extends Control

var selected_type: String = 'd6'
var old_type = null
var max_addable: bool = true
var type_radio_group: ButtonGroup = preload('res://Interface/TypeRadioGroup.tres')
var body_material = preload('res://dice/materials/Dice Body.material')
var number_material = preload('res://dice/materials/Numbers.material')
var outline_material = preload('res://dice/materials/outline.tres')

onready var dice_ui = {
	'd4': $d4,
	'd6': $d6,
	'd8': $d8,
	'd10': $d10,
	'd12': $d12,
	'd20': $d20,
}
var dice = {
	'd4': {'max': 0, 'amount': 0, 'rolled_sides': {}},
	'd6': {'max': 0, 'amount': 0, 'rolled_sides': {}},
	'd8': {'max': 0, 'amount': 0, 'rolled_sides': {}},
	'd10': {'max': 0, 'amount': 0, 'rolled_sides': {}},
	'd12': {'max': 0, 'amount': 0, 'rolled_sides': {}},
	'd20': {'max': 0, 'amount': 0, 'rolled_sides': {}},
}

signal add_die
signal clear_dice
signal roll
signal roll_invalid
signal lock_valid
signal scale_scene
signal zoom_camera

func _ready():
	$Body.color = body_material.albedo_color
	$Number.color = number_material.albedo_color
	$Border.color = outline_material.get_shader_param('border_color')
	for button in type_radio_group.get_buttons():
		if button.type == selected_type:
			button.pressed = true
	for type in dice_ui:
		dice_ui[type].connect('max_dice', self, 'max_changed')
	clear()

func max_changed(type: String, max_value: int):
	dice[type].max = max_value

func clear():
	clear_counters()
	emit_signal('clear_dice')

func clear_counters():
	$Counter.clear()
	for key in dice.keys():
		var die_type = key
		dice[die_type].amount = 0
		key.erase(0, 1)		# removes the d from the type ('d20')
		for side in range(int(key)+1):	# +1 because we use 0 for invalids
			dice[die_type].rolled_sides[side] = []

func update_all_counters(dice_type: String, current_side: int, dice_id: int):
	var sides = dice[dice_type].rolled_sides
	for side in sides:
		sides[side].erase(dice_id)
	sides[current_side].append(dice_id)
	update_counter()


func update_counter():
	$Counter.clear()
	var root = $Counter.create_item()

	for die_type in dice:
		var	amount: int = 0
		var side_sum: int = 0
		var rolled_sides: Dictionary = dice[die_type].rolled_sides

		var type_branch = new_tree_item(root, die_type)
		for side in rolled_sides:
			amount += rolled_sides[side].size()
			if not rolled_sides[side] == [] and not side == 0:
				new_tree_item(type_branch, '[' + str(side) + ']', str(rolled_sides[side].size()))
				side_sum += side * rolled_sides[side].size()
		if not rolled_sides[0] == []:	# put unknown dice side last
			new_tree_item(type_branch, '[?]', str(rolled_sides[0].size()))
		new_tree_item(type_branch, 'sum', str(side_sum))
		if amount == 0:
			type_branch.free()
		else:
			type_branch.set_text(1, str(amount))
		dice[die_type].amount = amount


func new_tree_item(parent: Object, key: String, value: String = '') -> TreeItem:
	var item: TreeItem = $Counter.create_item(parent)
	item.set_text(0, key)
	if value: item.set_text(1, value)
	return item

func _on_AddMaxDice_button_down():
	if not max_addable:
		return
	for type in dice:
		if dice[type].max <= 0:
			if dice[type].amount > 0:
				clear()
			continue
		if dice[type].amount >= dice[type].max:
			clear()
		for _i in dice[type].max - dice[type].amount:
			max_addable = false
			emit_signal('add_die', type)
			yield(get_tree().create_timer(.0003), 'timeout')
		max_addable = true


func _on_AddDie_button_down() -> void:
	selected_type = type_radio_group.get_pressed_button().type
	clear_counters()
	emit_signal('add_die', selected_type)

func _on_type_selected(button_pressed: bool) -> void:
	if button_pressed:
		old_type = selected_type
		selected_type = type_radio_group.get_pressed_button().type
		if old_type == selected_type:
			clear_counters()
			emit_signal('add_die', selected_type)

func _on_ClearDice_button_down() -> void:
	clear()

func _on_Roll_button_down() -> void:
	emit_signal('roll')

func _on_RollInvalidDice_button_down() -> void:
	emit_signal('roll_invalid')

func _on_LockValidDice_button_down() -> void:
	emit_signal('lock_valid')

func _on_AreaScale_value_changed(value: float) -> void:
	emit_signal('scale_scene', value)

func _on_CameraZoom_value_changed(value: float) -> void:
	emit_signal('zoom_camera', value)

func _on_AreaScale_CameraZoom(value: float) -> void:
	$CameraZoom.value = value


func _on_Body_color_changed(color: Color) -> void:
	body_material.albedo_color = color

func _on_Number_color_changed(color: Color) -> void:
	number_material.albedo_color = color

func _on_Border_color_changed(color: Color) -> void:
	outline_material.set_shader_param('border_color', color)


func _on_FeatureRequest_pressed() -> void:
	OS.shell_open('https://github.com/Qubus0/diceRoller/issues')
