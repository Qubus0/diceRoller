extends RigidBody
class_name Die, 'res://icon.png'

onready var MESH: MeshInstance = $Mesh
onready var BORDER: MeshInstance = $Mesh/Border
onready var COLLISION: CollisionShape = $CollisionShape

export var type: String
export var number_of_sides := 0
export var die_scale := 1.0

var time := 0.0

var sides := {}
var max_side_height_difference := 0.0

var mesh_scale := Vector3(die_scale, die_scale, die_scale)
var shrunk_mesh := mesh_scale - Vector3(0.1, 0.1, 0.1)
var mesh_tool := MeshDataTool.new()

var invalid := false setget set_invalid, get_invalid
var locked := false setget set_locked
var locked_material := preload('res://dice/materials/BodyLocked.material')

var state: int
enum states {NONE, HOVERED, CLICKED, DRAGGED}

signal die_rolled(type, rolled_side, instance_id)
signal die_died(type, instance_id)
signal die_respawn(type)


func _ready() -> void:
	assert(type and number_of_sides, 'Die "%s" is invalid | type: %s sides: %s' % [name, type, number_of_sides])
	if get_invalid():
		set_invalid(true)
	MESH.scale = mesh_scale
	COLLISION.scale = mesh_scale
	# border is the simplified version of the mesh (no numbers -> less vertices)
	# warning-ignore:return_value_discarded
	mesh_tool.create_from_surface(BORDER.mesh, 0)


func _process(delta: float) -> void:
	time += delta
	if time > 1:
		time = 0
		var rolled := get_rolled_side()
		if rolled <= 0:
			set_invalid(true)
		else:
			set_invalid(false)
		emit_signal('die_rolled', type, rolled, get_instance_id())
	if translation.y < -4:
		respawn()


func get_rolled_side() -> int:
	var highest_y := 0
	var highest_side := 0
	var heights := []
	for side in sides:
		var height := to_global(sides[side]).y
		heights.append(height)
		if height > highest_y:
			highest_y = height
			highest_side = side
	heights.sort()
	if heights[-1] - heights[-2] < max_side_height_difference:
		return 0
	return highest_side


func get_invalid() -> bool:
	if get_rolled_side() <= 0:
		invalid = true
	return invalid


func set_invalid(is_invalid: bool) -> void:
	invalid = is_invalid
	set_border_visible(invalid)


func set_border_visible(visible: bool) -> void:
	BORDER.set_visible(visible)
	MESH.scale = shrunk_mesh if visible else mesh_scale


func get_highest_y_position_global() -> float:
	var highest_y_position := to_global(Vector3.ZERO).y

	for vertex_index in mesh_tool.get_vertex_count():
		var vertex_y = to_global(mesh_tool.get_vertex(vertex_index)).y
		if vertex_y > highest_y_position:
			highest_y_position = vertex_y

	return highest_y_position


# the distance from the origin to the lowest point (at any orientation)
func get_origin_to_lowest_y_height() -> float:
	var lowest_y_position := to_global(Vector3.ZERO).y

	for vertex_index in mesh_tool.get_vertex_count():
		var vertex_y := to_global(mesh_tool.get_vertex(vertex_index)).y
		if vertex_y < lowest_y_position:
			lowest_y_position = vertex_y

	return to_global(Vector3.ZERO).y - lowest_y_position


func get_height() -> float:
	return MESH.get_transformed_aabb().size.y


func set_locked(is_locked: bool) -> void:
	locked = is_locked
	if is_locked:
		MESH.set_surface_material(0, locked_material)
		if SettingsData.get_setting("allow_locked_move"):
			self.axis_lock_angular_z = true
			self.axis_lock_angular_x = true
			self.axis_lock_angular_y = true
		else:
			self.mode = RigidBody.MODE_STATIC
			self.sleeping = true
	else:
		MESH.set_surface_material(0, null)
		if self.mode == RigidBody.MODE_STATIC:
			self.mode = RigidBody.MODE_RIGID
		self.axis_lock_angular_z = false
		self.axis_lock_angular_x = false
		self.axis_lock_angular_y = false
		self.sleeping = false


func respawn() -> void:
	emit_signal('die_respawn', type)
	die()


func die() -> void:
	emit_signal('die_died', type, get_instance_id())
	queue_free()


#func get_side_normals() -> void: 	# a helper for setting up new dice
#	print('var sides = {')
#	var mdt := MeshDataTool.new()
#	mdt.create_from_surface($Mesh/Border.mesh, 0) # border-> only edge mesh
#	for i in mdt.get_face_count():
#		print('	' + str(0) + ': Vector3' + str(mdt.get_face_normal(i)) + ',')
#	print('}')
