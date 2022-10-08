extends Container
# https://godotengine.org/qa/54343/can-scrollcontainer-resize-itself-to-its-children

onready var _child_container: Control = get_child(get_child_count()-1)


func _ready() -> void:
	fit_content()
	_child_container.connect("resized", self, "fit_content")


func fit_content() -> void:
	var size_parent_node : Control = get_parent()
	var y_margins := size_parent_node.get_combined_minimum_size().y - get_size().y
	rect_min_size.y = min(_child_container.get_size().y, size_parent_node.get_size().y - y_margins)
