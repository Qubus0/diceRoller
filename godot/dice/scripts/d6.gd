extends Die

func	 _init() -> void:
	max_side_height_difference = .4
	sides = {
		1: Vector3.DOWN,
		2: Vector3.BACK,
		3: Vector3.LEFT,
		4: Vector3.RIGHT,
		5: Vector3.FORWARD,
		6: Vector3.UP,
	}

# since the sides of the d6 correspond to the local x/y/z axes, which we get
# as globals, we can check if their y (up) direction is ~1
#func get_rolled_side() -> int:
#	if transform.basis.y.y > .9: # top is up
#		return 6
#	elif transform.basis.y.y < -.9: # bottom is up
#		return 1
#	elif transform.basis.x.y > .9: # right side is up
#		return 4
#	elif transform.basis.x.y < -.9: # left side is up
#		return 3
#	elif transform.basis.z.y > .9: # front side is up
#		return 2
#	elif transform.basis.z.y < -.9: # back side is up
#		return 5
#	else:
#		return 0
