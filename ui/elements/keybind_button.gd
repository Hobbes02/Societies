extends Button

@export var keybind: String = ""
@onready var error_keybind_not_found: String = "keybind '"+keybind+"' not found"


func _ready() -> void:
	assert(InputMap.has_action(keybind), error_keybind_not_found)
	set_process_unhandled_key_input(false)
	display_current_key()


func _toggled(is_button_pressed):
	set_process_unhandled_key_input(is_button_pressed)
	if is_button_pressed:
		text = "... Key"
		release_focus()
	else:
		display_current_key()


func _unhandled_key_input(event):
	remap_action_to(event)
	button_pressed = false


func remap_action_to(event):
	Settings.write_read.store_var(event)
	text = "%s Key" % event.as_text()


func display_current_key():
	var current_key = InputMap.action_get_events(keybind)[0].as_text()
	text = "%s Key" % current_key
