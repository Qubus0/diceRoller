extends VBoxContainer
class_name DiceCommandsInput

var error := false setget set_error
var parsed_command: DiceCommand
var rng = RandomNumberGenerator.new()

onready var error_icon: TextureRect = $HBox/Error
onready var run_button: TextureButton = $HBox/RunCommand

signal toast_error(message, delay, lifetime)
signal execute_command(command)


func _ready() -> void:
	parse($HBox/CommandInput.text)
#	yield(get_tree().create_timer(.5), "timeout")
#	try_execute_command()


func parse(command: String) -> void:
	parsed_command = DiceCommand.new(command)
	self.error = parsed_command.error

	error_icon.hint_tooltip = ""
	for message in parsed_command.messages:
		error_icon.hint_tooltip += message + "\n"


func try_execute_command():
	if error:
		var message = "Unable to roll!"
		var lifetime = 2
		for m in parsed_command.messages:
			message += "\n" + m
			lifetime += 5
		emit_signal("toast_error", message, 0, lifetime)
		return

	emit_signal("execute_command", parsed_command)


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


