tool
extends AspectRatioContainer

export var left := false setget set_left_clicked
export var right := false setget set_right_clicked
export var default_color := Color.darkgray
export var highlight_color := Color.white


func _ready() -> void:
	for child in get_children():
		child.self_modulate = default_color
	if left:
		$Left.self_modulate = highlight_color
	if right:
		$Right.self_modulate = highlight_color


func set_left_clicked(clicked: bool) -> void:
	left = clicked
	if clicked:
		$Left.self_modulate = highlight_color
	else:
		$Left.self_modulate = default_color


func set_right_clicked(clicked: bool) -> void:
	right = clicked
	if clicked:
		$Right.self_modulate = highlight_color
	else:
		$Right.self_modulate = default_color
