extends VBoxContainer
class_name DiceCommands

var error := false setget set_error
var parsed_command: Dictionary
var rng = RandomNumberGenerator.new()

onready var error_icon: TextureRect = $HBox/Error
onready var run_button: TextureButton = $HBox/RunCommand

signal toast_error(message, delay, lifetime)
signal execute_command(parsed_command)


func _ready() -> void:
	parse("")


func parse(command: String) -> void:
	parsed_command = dice_syntax.dice_parser(command)
	self.error = parsed_command.error

	error_icon.hint_tooltip = ""
	for message in parsed_command.msg:
		error_icon.hint_tooltip += message + "\n"


func try_execute_command():
	print()
	print("-------- Error: %s" % error)
	print(JSON.print(parsed_command, "  "))
	print()

	if error:
		var message = "Unable to roll!"
		var lifetime = 2
		for m in parsed_command.msg:
			message += "\n" + m
			lifetime += 5
		emit_signal("toast_error", message, 0, lifetime)
		return

	emit_signal("execute_command", parsed_command)

#	rng.randomize()
#	var result = dice_syntax.roll_parsed(parsed_command, rng)
#
#
#	print("---")
#	print(JSON.print(result, "  "))
#	print()


func set_error(is_error: bool) -> void:
	error = is_error
	error_icon.visible = is_error
	run_button.visible = not is_error


func _on_CommandInput_text_entered(_new_text: String) -> void:
	run_button.emit_signal("pressed")


func _on_CommandInput_text_changed(new_text: String) -> void:
	parse(new_text)


func _on_RunCommand_pressed() -> void:
	try_execute_command()


