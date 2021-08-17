extends Spatial

export (PackedScene) var d4 = null
export (PackedScene) var d6 = null
export (PackedScene) var d8 = null
export (PackedScene) var d10 = null
export (PackedScene) var d12 = null
export (PackedScene) var d20 = null
export (float) var global_area_scale = .2

var dice_locked = false

var max_dice = {
	'd4': 0,
	'd6': 0,
	'd8': 0,
	'd10': 0,
	'd12': 0,
	'd20': 0,
}

var current_dice = {
	'd4': 0,
	'd6': 0,
	'd8': 0,
	'd10': 0,
	'd12': 0,
	'd20': 0,
}

signal area_scale_camera_zoom

func _ready():
	randomize()
	$Interface.connect('max_dice', self, 'update_max_dice')
	$Interface.connect('add_max', self, 'add_max_dice')
	$Interface.connect('add_die', self, 'new_die')
	$Interface.connect('clear', self, 'clear_dice')
	$Interface.connect('roll', self, 'roll_all')
	$Interface.connect('roll_invalid', self, 'roll_invalid')
	$Interface.connect('lock_valid', self, 'lock_valid')
	$Interface.connect('scale_scene', self, 'scale_scene')
	$Interface.connect('zoom_camera', self, 'zoom_camera')
	connect('area_scale_camera_zoom', $Interface, '_on_AreaScale_CameraZoom')
	scale_scene(global_area_scale)


func update_max_dice(type, max_value):
	max_dice[type] = max_value

func add_max_dice():
	var infinite = true
	for type in max_dice:
		if max_dice[type] > 0:
			infinite = false
			break
	if infinite:
		return
	
	for type in current_dice:	# reset counter
		current_dice[type] = 0
	for die in $AllDice.get_children(): # count dice by type
		current_dice[die.type] += 1
		if current_dice[die.type] > max_dice[die.type]: # if exceeds set max
			clear_dice()
			for type in current_dice:	# reset because cleared
				current_dice[type] = 0
				
	for type in max_dice:	# add difference of current to set max
		for _i in range(max_dice[type] - current_dice[type]):
			new_die(type)


func new_die(type):
	$Interface.clear_counters()
	var newDie
	match type: 
		'd6': newDie = d6.instance()
		'd20': newDie = d20.instance()
		_: newDie = d6.instance()

	$AllDice.add_child(newDie)
	newDie.connect('die_rolled', $Interface, 'update_all_counters')
	newDie.connect('die_died', self, 'new_die')
	randomize_throw(newDie)

func clear_dice() -> void:
	$Interface.clear_labels()
	for child in $AllDice.get_children():
		$AllDice.remove_child(child)

func scale_scene(scale):
	global_area_scale = scale
	$Box.scale = Vector3(global_area_scale, global_area_scale, global_area_scale)
	var offset = global_area_scale*5 -1
	var offsets = [32, 24, 16, 8, 0]
	emit_signal('area_scale_camera_zoom', offsets[offset])

func zoom_camera(offset):
	$Path/PathFollow.offset = offset

func randomize_throw(die):
	var area_size_x = $Box/Floor/CollisionShape.get_shape().extents.x * global_area_scale
	var area_size_z = $Box/Floor/CollisionShape.get_shape().extents.z * global_area_scale
	die.global_transform.origin = Vector3(
		(randi() % int(area_size_x)) - (area_size_x/2),
		(10 * global_area_scale + randi() % 5), 
		(randi() % int(area_size_z)) - (area_size_z/2))
	die.linear_velocity = Vector3(
		randi() % 4 -2,
		0,
		randi() % 4 -2
	)
	die.angular_velocity = Vector3(
		randi() % 30 -15,
		randi() % 30 -15,
		randi() % 30 -15
	)

func roll_all():
	for die in $AllDice.get_children():
		roll(die)
		
func roll_invalid():
	for die in $AllDice.get_children():
		if die.invalid == true:
			roll(die)

func lock_valid():
	if not dice_locked:
		for die in $AllDice.get_children():
			if die.invalid == false:
				die.mode = RigidBody.MODE_STATIC	
		dice_locked = true
	else: 
		for die in $AllDice.get_children():
			die.mode = RigidBody.MODE_RIGID
		dice_locked = false
	print(dice_locked)

func roll(die):
	die.linear_velocity = Vector3(
			randi() % 4 -2,
			(10 + randi() % int(global_area_scale*5) * 5),
			randi() % 4 -2
	)
	die.angular_velocity = Vector3(
		randi() % 30 -15,
		randi() % 30 -15,
		randi() % 30 -15
	)
