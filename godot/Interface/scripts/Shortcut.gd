tool
extends HBoxContainer

export var shortcut: String setget set_shortcut

var default_color := Color('#8d697a')
var highlight_color := Color('#ffecd6')

var mouse_input := preload('res://Interface/MouseInput.tscn')
var key_input := preload('res://Interface/KeyInput.tscn')


func _ready() -> void:
	# fixes some duplication errors
	set_shortcut(shortcut)


func set_shortcut(new_shortcut: String) -> void:
	shortcut = new_shortcut
	for child in get_children():
		child.queue_free()
	build_shortcut()


func build_shortcut() -> void:
	var is_input := false
	var input := ''
	var text := ''
	for character in shortcut:
		match character:
			'[':
				add_text_label(text)
				is_input = true
				text = ''
			']':
				add_input_symbol(input, text)
				is_input = false
				input = ''
				text = ''
			'=':
				is_input = false
			_:
				if is_input:
					input += character
				else:
					text += character
	add_text_label(text)


func add_input_symbol(input: String, label: String = '') -> void:
	if not input:
		return
	match input:
		'lmb':
			var mouse := mouse_input.instance()
			mouse.default_color = default_color
			mouse.highlight_color = highlight_color
			add_child(mouse)
			mouse.left = true
		'rmb':
			var mouse := mouse_input.instance()
			mouse.default_color = default_color
			mouse.highlight_color = highlight_color
			add_child(mouse)
			mouse.right = true
		'key':
			var key := key_input.instance()
			key.text = label
			add_child(key)


func add_text_label(text: String) -> void:
	if not text:
		return
	var plain_text := Label.new()
	plain_text.text = text
	add_child(plain_text)

