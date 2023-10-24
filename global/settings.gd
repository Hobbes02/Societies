extends Node

var tab: int = 0

@onready var keybinds: Dictionary = {}
var keys_by_keycodes: Dictionary = {
	1: "Left Click",
	2: "Right Click",
	3: 'Middle Mouse Button',
	4: 'Mouse Wheel Up',
	5: 'Mouse Wheel Down',
	81: "Q",
	87: "W",
	69: "E",
	82: "R",
	84: "T",
	89: 'Y',
	85: 'U',
	73: 'I',
	79: 'O',
	80: 'P',
	65: 'A',
	83: 'S',
	68: 'D',
	70: 'F',
	71: 'G',
	72: 'H',
	74: 'J',
	75: 'K',
	76: 'L',
	90: 'Z',
	88: 'X',
	67: 'C',
	86: 'V',
	66: 'B',
	78: 'N',
	77: 'M',
	49: '1',
	50: '2',
	51: '3',
	52: '4',
	53: '5',
	54: '6',
	55: '7',
	56: '8',
	57: '9',
	48: '0',
	32: 'Space',
	45: "Minus",
	61: "Equal",
	92: "BackSlash",
	91: "BracketLeft",
	93: "BracketRight",
	59: "Semicolon",
	39: "Apostrophe",
	96: "QuoteLeft",
	44: "Comma",
	46: "Period",
	47: "Slash",
	4194325: "Shift",
	4194306: "Tab",
	4194329: "CapsLock",
	4194326: "Ctrl",
	4194328: "Alt",
	4194308: "Backspace",
	4194309: "Enter",
	4194319: "Left",
	4194320: "Up",
	4194322: "Down",
	4194321: "Right",
	4194305: 'Escape',
	4194311: 'Insert',
	4194312: 'Delete',
	4194327: 'Windows',
	4194332: 'F1',
	4194333: 'F2',
	4194334: 'F3',
	4194335: 'F4',
	4194336: 'F5',
	4194337: 'F6',
	4194338: 'F7',
	4194340: 'F9',
	4194341: 'F10',
	4194342: 'F11',
	4194343: 'F12',
	4194344: 'F13',
}


func _ready() -> void:
	get_custom_actions()
	print(keybinds)


func get_custom_actions():
	for action in InputMap.get_actions():
		if not str(action).contains("ui"):
			keybinds[str(action)] = get_action_keys(action)


func get_action_keys(action: String):
	for key in InputMap.action_get_events(action):
		if key is InputEventKey:
			return(key.physical_keycode)
		elif key is InputEventMouseButton:
			return(key.button_index)


func _on_keybind_changer_key_changed(action: String, event: InputEvent) -> void:
	keybinds[action] = event
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
