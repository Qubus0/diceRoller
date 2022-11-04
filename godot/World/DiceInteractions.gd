extends Spatial

var mouse_position: Vector3
var hovered_die: Die setget set_hovered_die
var min_dragging_height := 1.0
var dragging_height := min_dragging_height
var max_throw_speed := 80
var rotation_direction := 0

var mouse_ray: RayCast


func _ready() -> void:
	mouse_ray = RayCast.new()
	mouse_ray.debug_shape_thickness = 0
	mouse_ray.collision_mask = 2
	add_child(mouse_ray)
	for except in $'/root/main/Box/OtherBoxSides'.get_children():
		mouse_ray.add_exception(except)
	mouse_ray.enabled = true


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(hovered_die):
		hovered_die = null

	if hovered_die and hovered_die.state == Die.states.DRAGGED:
		if OS.has_feature('HTML5'): # html export has these reversed
			Input.set_default_cursor_shape(Input.CURSOR_CAN_DROP)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		move_die_to_mouse(hovered_die)

	var viewport_mouse_position := get_viewport().get_mouse_position()
	var camera := get_viewport().get_camera()

	# Project mouse into a 3D ray
	var ray_origin := camera.project_ray_origin(viewport_mouse_position)
	var ray_direction := camera.project_ray_normal(viewport_mouse_position)
	mouse_ray.translation = ray_origin
	mouse_ray.cast_to =  mouse_ray.to_local(ray_origin + ray_direction * (ray_origin.distance_to(Vector3.ZERO) + 10))

	# use the raycast for targeting dice, but use a y plane to get the mouse_position
	mouse_position = get_mouse_position_on_y_plane(ray_origin, ray_direction, dragging_height)

	# only accept the ray cast when a die is hit
	var hit_die := mouse_ray.get_collider() as Die
	if hit_die:
		# avoid losing a die when the mouse moves off the dragged die
		if not hovered_die or not hovered_die.state == Die.states.DRAGGED:
			set_hovered_die(hit_die)
		return

	if hovered_die and not hovered_die.state == Die.states.DRAGGED:
		set_hovered_die(null)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			$GrabArea.space_override = Area.SPACE_OVERRIDE_DISABLED
	if event is InputEventMouseMotion:
		$GrabArea.translation = mouse_position

	if not hovered_die or not is_instance_valid(hovered_die):
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
			if event.pressed:
				dragging_height = $GrabArea/CollisionShape.shape.radius/2
				$GrabArea.translation = mouse_position
				$GrabArea.space_override = Area.SPACE_OVERRIDE_REPLACE
		return

	# only direct dice interactions
	if event is InputEventMouseMotion:
		if hovered_die.state == Die.states.CLICKED:
			hovered_die.state = Die.states.DRAGGED

	handle_mouse_button_event(event)
	handle_key_event(event)


func handle_mouse_button_event(mouse_button_event: InputEventMouseButton):
	if not mouse_button_event:
		return

	if mouse_button_event.button_index == BUTTON_LEFT:
		if mouse_button_event.doubleclick:
			throw_die_randomly(hovered_die)
		elif mouse_button_event.is_pressed() and hovered_die.state == Die.states.HOVERED:
			hovered_die.state = Die.states.CLICKED
		elif not mouse_button_event.is_pressed() and hovered_die.state == Die.states.DRAGGED:
			hovered_die.state = Die.states.HOVERED
			reset_forces(hovered_die)
			throw_die_in_drag_direction(hovered_die)

	if mouse_button_event.button_index == BUTTON_RIGHT and mouse_button_event.is_pressed():
		if hovered_die.state == Die.states.HOVERED:
			hovered_die.set_locked(!hovered_die.locked)
		elif hovered_die.state == Die.states.DRAGGED:
			hovered_die.state = Die.states.HOVERED
			put_die_down(hovered_die)


func handle_key_event(key_event: InputEventKey):
	if not key_event:
		return

	if hovered_die.state == Die.states.DRAGGED:
		if key_event.is_action_pressed('left'):
			rotation_direction = -1
			rotate_die()
			$RotateTicks.start()
		elif key_event.is_action_pressed('right'):
			rotation_direction = 1
			rotate_die()
			$RotateTicks.start()
		elif key_event.is_action_released('left') or \
		key_event.is_action_released('right'):
			rotation_direction = 0
			$RotateTicks.stop()
			$RotateTicks.wait_time = 0.2

	if key_event.is_action_pressed('down'):
		if hovered_die.state == Die.states.HOVERED:
			hovered_die.set_locked(!hovered_die.locked)
		elif hovered_die.state == Die.states.DRAGGED:
			hovered_die.state = Die.states.HOVERED
			put_die_down(hovered_die)

	if key_event.is_action_pressed('up'):
		hovered_die.set_locked(false)
		hovered_die.state = Die.states.NONE
		dragging_height = min_dragging_height
		throw_die_randomly(hovered_die)

	if key_event.is_action_pressed('delete'):
		hovered_die.die()
		hovered_die = null


func throw_die_in_drag_direction(die: Die):
	var throw := (mouse_position - die.translation) * Vector3(100, 0, 100)
	var throw_clamped :=  clamp(throw.length(), 0, max_throw_speed) * throw.normalized()
	die.linear_velocity = throw_clamped
	die.angular_velocity = - throw.cross(Vector3.UP)


func throw_die_randomly(die: Die):
	die.linear_velocity = Vector3(-1 + randi() % 3, 20, -1 + randi() % 3)
	die.angular_velocity = Vector3(-15 + randi() % 30, -15 + randi() % 30, -15 + randi() % 30)


func get_mouse_position_on_y_plane(ray_origin: Vector3, ray_direction: Vector3, plane_offset: float = 0.0) -> Vector3:
	if ray_direction.y == 0: return Vector3.ZERO # unlikely devision by 0
	var distance := (-ray_origin.y + plane_offset) / ray_direction.y
	var y_plane_hit_position := ray_origin + ray_direction * distance
	return y_plane_hit_position


func set_hovered_die(die):
	if die == hovered_die:
		return
	if die is Die:
		die.state = Die.states.HOVERED
		if not die.is_connected('mouse_exited', self, '_on_die_mouse_exited'):
			die.connect('mouse_exited', self, '_on_die_mouse_exited', [die])
		hovered_die = die
		if OS.has_feature('HTML5'): # html export has these reversed
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_CAN_DROP)
	elif hovered_die and die == null: # anything else while hovered die is still set
		if hovered_die.is_connected('mouse_exited', self, '_on_die_mouse_exited'):
			hovered_die.disconnect('mouse_exited', self, '_on_die_mouse_exited')
		hovered_die = null
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func move_die_to_mouse(die: Die) -> void:
	reset_forces(die)
	var drag_position := Vector3(mouse_position.x, dragging_height, mouse_position.z)
	drag_position = avoid_obstacles(drag_position)
	die.translation = drag_position
	rotate_rolled_side_up(die)


func avoid_obstacles(drag_position: Vector3) -> Vector3:
	# adjust dragging height to go above other dice
	var avoid: Area = $MinDistance
	avoid.translation = drag_position
	if avoid.get_overlapping_bodies().size() > 1: # ignore current die
		dragging_height += .1
	elif	 $MinDistance/MaxDistance.get_overlapping_bodies().size() <= 1:
		if dragging_height > min_dragging_height:
			dragging_height -= .1
	return Vector3(mouse_position.x, dragging_height, mouse_position.z)


func rotate_rolled_side_up(die: Die) -> void:
	# aligns the rolled side perfectly with Vector3.UP -> less wonky rotation
	var side := die.get_rolled_side()
	if side > 0:
		var side_direction := (die.to_global(die.sides[side]) - die.translation).normalized()

		# don't rotate if they are already the same
		if side_direction.is_equal_approx(Vector3.UP):
			return

		var rotation_axis := side_direction.cross(Vector3.UP)
		var angle := side_direction.angle_to(Vector3.UP)
		die.rotate(rotation_axis.normalized(), angle)


func put_die_down(die: Die) -> void:
	reset_forces(die)
	dragging_height = min_dragging_height
	var y_position := die.get_origin_to_lowest_y_height()

	# so dice are stacked on top of each other instead of clipping
	var ray := RayCast.new()
	ray.collision_mask = 2
	ray.translation = die.translation
	ray.cast_to = Vector3.DOWN * die.translation.distance_to(Vector3.ZERO)
	add_child(ray)
	ray.add_exception(die)		# don't hit self
	ray.force_raycast_update() 	# can't wait for the physics frame

	var hit_die := ray.get_collider() as Die
	if hit_die:
		y_position += hit_die.get_highest_y_position_global()
	ray.queue_free()

	die.translation = Vector3(mouse_position.x, y_position, mouse_position.z)
	die.set_locked(true)


func reset_forces(die: Die) -> void:
	hovered_die.sleeping = false
	die.linear_velocity = Vector3.ZERO
	die.angular_velocity = Vector3.ZERO


func _on_die_mouse_exited(die: Die) -> void:
	if not hovered_die or not die == hovered_die:
		return
	if not die.state == Die.states.DRAGGED and not die.state == Die.states.CLICKED:
		die.state = Die.states.NONE
		set_hovered_die(null)


func _on_RotateTicks_timeout() -> void:
	rotate_die()
	if $RotateTicks.wait_time > 0.06:
		$RotateTicks.wait_time -= 0.02


func rotate_die() -> void:
	hovered_die.rotate(Vector3.UP, PI/32 * rotation_direction)

