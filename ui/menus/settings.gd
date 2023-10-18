extends Control

@onready var tabs: TabContainer = $TabContainer


func _ready() -> void:
	tabs.current_tab = Settings.tab


func _on_keybind_changer_key_changed(action, event) -> void:
	Settings.keybinds[action] = event
