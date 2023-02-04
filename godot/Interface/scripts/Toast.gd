extends PanelContainer
class_name Toast

var message: String
var toasted_height := 0.0
var untoasted_height := 0.0
var delay := 0.0
var lifetime := -1.0
var margin := 30

onready var tw: Tween = $Tween


func _ready() -> void:
#	modulate = Color.transparent
	$Message.bbcode_text = message
	$TextSpaceCorrecter.text = $Message.text
	$C/ProgressBar.max_value = lifetime
	$C/ProgressBar.value = lifetime

	# force rect to resize
	hide()
	show()
	yield(get_tree(), "idle_frame")

	set_anchors_and_margins_preset(Control.PRESET_BOTTOM_RIGHT)
	margin_top -= margin
	margin_left -= margin
	margin_right -= margin

	toasted_height = margin_top
	untoasted_height = margin_top + rect_size.y + margin*2
	set_toast_height(untoasted_height)

	popup()


func popup():
	modulate = Color.white
	tw.interpolate_method(
		self, "set_toast_height",
		untoasted_height, toasted_height, 1,
		Tween.TRANS_BACK, Tween.EASE_OUT, delay
	)
	tw.start()


func set_toast_height(pos: float):
	margin_top = pos
	margin_bottom = pos - rect_size.y


func _on_Tween_tween_all_completed() -> void:
	if lifetime > 0:
		tw.interpolate_property($C/ProgressBar, "value", lifetime, 0, lifetime)
		tw.start()
		$Lifetime.start(lifetime)


func _on_Message_meta_clicked(meta) -> void:
	OS.shell_open(meta)


func _on_Dismiss_pressed() -> void:
	queue_free()


func _on_Lifetime_timeout() -> void:
	queue_free()


