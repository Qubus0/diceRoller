extends RigidBody
class_name Die, 'res://dice/scripts/abstractDie.gd'

export (String) var type = ''
export (int) var number_of_sides = 0
export (float) var die_scale = 1

var sides = {}
var max_side_height_difference = 0
var mesh_scale
var shrunk_mesh
var invalid: bool = false

signal die_rolled
signal die_died
signal die_removed

func _ready() -> void:
	if not type or not number_of_sides:
		assert(false, self.name + ' data is invalid | type: ' + str(type) + ' sides: ' + str(number_of_sides))
	mesh_scale = Vector3(die_scale, die_scale, die_scale)
	shrunk_mesh = Vector3(die_scale - 0.1, die_scale - 0.1, die_scale - 0.1)
	$Mesh.scale = mesh_scale
	$CollisionShape.scale = mesh_scale
#	get_side_normals()

# Called every frame. 'delta' is the elapsed time since the previous frame.
var time = 0
func _process(delta: float) -> void:
	time += delta
	if time > 1:
		time = 0
		var value = get_rolled_side()
		show_border_when_invalid(value)
		emit_signal('die_rolled', type, value, int(get_instance_id()))
	if translation.y < -10:
		respawn()

func get_rolled_side() -> int:
	var highest = 0
	var highest_side = 0
	var heights = []
	for side in sides:
		var height = to_global(sides[side]).y
		heights.append(height)
		if height > highest:
			highest = height
			highest_side = side
	heights.sort()
	if heights[-1] - heights[-2] < max_side_height_difference:
		return 0
	return highest_side

func _input_event(_camera: Object, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int):
	if event is InputEventMouseButton \
	and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			linear_velocity = Vector3(
				randi() % 3 -1,
				20,
				randi() % 3 -1
			)
			self.angular_velocity = Vector3(
				randi() % 30 -15,
				randi() % 30 -15,
				randi() % 30 -15
			)
		if event.button_index == BUTTON_RIGHT:
			removed()

func show_border_when_invalid(value):
	if value == 0:
		invalid = true
		$Mesh.scale = shrunk_mesh
		$Mesh/Border.set_visible(true)
	else:
		invalid = false
		$Mesh.scale = mesh_scale
		$Mesh/Border.set_visible(false)

func respawn():
	queue_free()
	emit_signal('die_died', type)

func removed():
	queue_free()
	emit_signal('die_removed')

#func get_side_normals():	# just a helper for setting up new dice
#	print('var sides = {')
#	var mdt = MeshDataTool.new()
#	mdt.create_from_surface($Mesh/Border.mesh, 0) # border-> only edge mesh
#	for i in mdt.get_face_count():
#		print('	' + str(0) + ': Vector3' + str(mdt.get_face_normal(i)) + ',')
#	print('}')
