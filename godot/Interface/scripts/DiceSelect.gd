extends TextureButton

export (String) var type
signal max_dice

func _ready() -> void:
	group = preload('res://Interface/TypeRadioGroup.tres')

func _on_DiceMax_text_changed(max_value: String) -> void:
	if int(max_value) or max_value == '':
		emit_signal('max_dice', type, int(max_value))
