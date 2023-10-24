extends HBoxContainer

signal key_changed(action, event)

@export var action: String = ""
@onready var action_label: Label = $ActionName
@onready var chng_key_bttn: Button = $ChangeKey

func _ready() -> void:
	chng_key_bttn.set_process_unhandled_input(false)
	action_label.text = (action.replace("_", " ")).capitalize()
	update_text()


func update_text():
	chng_key_bttn.text = str(Settings.keys_by_keycodes[Settings.keybinds[action]])


func _on_change_key_pressed() -> void:
	chng_key_bttn.set_process_unhandled_input(true)


func _on_key_pressed(keycode: int, event: InputEvent) -> void:
	chng_key_bttn.set_process_unhandled_input(false)
	chng_key_bttn.set_pressed_no_signal(false)
	emit_signal("key_changed", action, event)
	chng_key_bttn.text = Settings.keys_by_keycodes[keycode]
