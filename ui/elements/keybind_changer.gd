extends HBoxContainer

signal key_changed(action, event)

@export var action: String = ""
var keycode: String = str_to_var(Settings.keybinds[action])
var keys_by_keycodes: Dictionary = {
	"1": "Left Click",
	"2": "Right Click",
	"81": "Q",
	"87": "W",
	"69": "E",
	"82": "R",
	"84": "T",
	"89": 'Y',
	"85": 'U',
	"73": 'I',
	"79": 'O',
	"80": 'P',
	"65": 'A',
	"83": 'S',
	"68": 'D',
	"70": 'F',
	"71": 'G',
	"72": 'H',
	"74": 'J',
	"75": 'K',
	"76": 'L',
	"90": 'Z',
	"88": 'X',
	"67": 'C',
	"86": 'V',
	"66": 'B',
	"78": 'N',
	"77": 'M',
	"45": "Minus",
	"62": "Equal",
	"92": "BackSlash",
	"91": "BracketLeft",
	"93": "BracketRight",
	"59": "Semicolon",
	"39": "Apostrophe",
	"96": "QuoteLeft",
	"44": "Comma",
	"46": "Period",
	"47": "Slash",
	"4194325": "Shift",
	"4194306": "Tab",
	"4194329": "CapsLock",
	"4194326": "Ctrl",
	"4194328": "Alt",
	"4194308": "Backspace",
	"4194309": "Enter",
	"4194319": "Left",
	"4194320": "Up",
	"4194322": "Down",
	"4194321": "Right",
}
@onready var action_label: Label = $ActionName
@onready var chng_key_bttn: Button = $ChangeKey

func _ready() -> void:
	chng_key_bttn.set_process_unhandled_input(false)
	action_label.text = action
	chng_key_bttn.text = keys_by_keycodes[keycode]


func _on_change_key_pressed() -> void:
	chng_key_bttn.set_process_unhandled_input(true)


func _on_key_pressed(event_name,event_code) -> void:
	emit_signal("key_changed",action,event_code)
	chng_key_bttn.text = event_name
