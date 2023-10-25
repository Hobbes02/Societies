extends Control

@onready var tabs: TabContainer = $TabContainer


func _ready() -> void:
	if SceneManager.get_persistent_information("settings_tab") != null:
		tabs.current_tab = SceneManager.get_persistent_information("settings_tab")
		SceneManager.set_persistent_information("settings_tab", 0)


func _on_back_button_pressed() -> void:
	SceneManager.change_scene(SceneManager.scene_history[-2])
