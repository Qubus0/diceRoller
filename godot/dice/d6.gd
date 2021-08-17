extends Die


func get_rolled_side() -> int:
	if transform.basis.y.y > .9: # top is up
		return 6
	elif transform.basis.y.y < -.9: # bottom is up
		return 1
	elif transform.basis.x.y > .9: # right side is up
		return 3
	elif transform.basis.x.y < -.9: # left side is up
		return 4
	elif transform.basis.z.y > .9: # front side is up
		return 5
	elif transform.basis.z.y < -.9: # back side is up
		return 2
	else:
		return 0
	
