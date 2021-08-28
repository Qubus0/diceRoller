extends Die

func _ready() -> void:
	max_side_height_difference = .6
	sides = {
		1: -Vector3(0.471405, 0.333333, 0.816496),
		2: -Vector3(0.471404, 0.333333, -0.816497),
		3: -Vector3(-0.942809, 0.333334, -0),
		4: -Vector3(0, -1, 0),
	}
