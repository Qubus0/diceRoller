extends Die
class_name MockDie

var side := 0


func _init(mock_type: String, mock_side: int, mock_group_id: String) -> void:
	type = mock_type
	side = mock_side
	assert(side <= int(type), "Mock side must not be greater than what the die type allows")
	group_id = mock_group_id

	for side in int(type):
		sides[side] = null


func get_rolled_side() -> int:
	return side

