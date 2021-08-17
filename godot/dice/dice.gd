extends RigidBody
class_name Die, 'res://dice/dice.gd'

export (String) var type = 'd6';
export (int) var number_of_sides = 6
export (float) var die_scale = 1

var mesh_scale
var shrunk_mesh
var invalid : bool = false

signal die_rolled
signal die_died

func _ready() -> void:
	mesh_scale = Vector3(die_scale, die_scale, die_scale)
	shrunk_mesh = Vector3(die_scale - 0.04, die_scale - 0.04, die_scale - 0.04)
	show_border_when_invalid(1)
	$Mesh.scale = mesh_scale
	$Collision.scale = mesh_scale

# Called every frame. 'delta' is the elapsed time since the previous frame.
var time = 0
func _process(delta: float) -> void:
	time += delta
	if time > .5:
		time = 0
		var value = get_rolled_side() if get_rolled_side() != 0 else '?'
		
		show_border_when_invalid(value)
		var id = self.get_instance_id()
		emit_signal('die_rolled', type, value, id)
	if self.translation.y < -10:
		remove_self()
		
func get_rolled_side():
	pass

func _input_event(_camera: Object, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int):
	if event is InputEventMouseButton \
	and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			self.linear_velocity = Vector3(
				randi() % 3 -1,
				20,
				randi() % 3 -1
			)
			self.angular_velocity = Vector3(
				randi() % 30 -15,
				randi() % 30 -15,
				randi() % 30 -15
			)
#		if event.button_index == BUTTON_RIGHT:
#			remove_self()		# send signal to update counter

func show_border_when_invalid(value):
	if str(value) == '?':
		invalid = true
		$Mesh.scale = shrunk_mesh
		$Mesh/Border.set_visible(true)
	else:
		invalid = false
		$Mesh.scale = mesh_scale
		$Mesh/Border.set_visible(false)

func remove_self():
	self.queue_free()
	emit_signal('die_died', type)
