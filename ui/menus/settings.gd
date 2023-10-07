extends Control

@onready var tabs: TabContainer = $TabContainer
@onready var keybind_popup: Window = $TabContainer/Keybinds/ChangeKeybind


func _ready() -> void:
	tabs.current_tab = Settings.tab


func _process(delta: float) -> void:
	pass


func _on_walk_left_change_primary_pressed() -> void:
	keybind_popup.show()



func _on_confirm_button_pressed() -> void:
	keybind_popup.hide()


func _on_cancel_button_pressed() -> void:
	keybind_popup.hide()
