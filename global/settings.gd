extends Node

var tab: int = 0

@onready var keybinds: Dictionary = {}


func _ready() -> void:
	get_custom_actions()
	print(keybinds)


func get_custom_actions():
	for action in InputMap.get_actions():
		if not str(action).contains("ui"):
			keybinds[str(action)] = get_action_keys(action)


func get_action_keys(action):
	for key in InputMap.action_get_events(action):
		if key is InputEventKey:
			return(key.physical_keycode)
		elif key is InputEventMouseButton:
			return(key.button_index)
