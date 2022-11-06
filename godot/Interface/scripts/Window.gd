tool
extends PanelContainer
class_name Window

export var window_title := ''
export var icon: Texture
export var window_content: PackedScene
var drag_position = null


signal moved(window)


func _ready() -> void:
	$Container/TitleBar/Margin/Container/Title.text = window_title
	$ReopenControl/Panel/ReopenTitle.text = window_title
	if window_content:
		$Container.add_child(window_content.instance())
	if icon:
		$ReopenControl/Icon/TextureRect.texture = icon


func _on_Window_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		emit_signal('moved', self)


func _on_TitleBar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			emit_signal('moved', self)
			drag_position = get_global_mouse_position() - rect_position
		else:
			drag_position = null

	if event is InputEventMouseMotion and drag_position != null:
		set_position(get_global_mouse_position() - drag_position)
		move_inside_bounds()


func move_inside_bounds() -> void:
	var bounds := get_viewport_rect()

	if rect_position.x + rect_size.x > bounds.end.x:
		rect_position.x = bounds.end.x - rect_size.x

	if rect_position.y + rect_size.y > bounds.end.y:
		rect_position.y = bounds.end.y - rect_size.y

	if rect_position.x < bounds.position.x:
		rect_position.x = bounds.position.x

	if rect_position.y < bounds.position.y:
		rect_position.y = bounds.position.y


func hide() -> void:
	$ReopenControl.show()
	$Background.hide()
	$Container.hide()


func show() -> void:
	$ReopenControl.hide()
	$Background.show()
	$Container.show()


func _on_CloseButton_pressed() -> void:
	hide()


func _on_Reopen_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			show()

