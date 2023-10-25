extends Control


func _on_play_button_pressed() -> void:
	SceneManager.change_scene("res://world/world.tscn")


func _on_credits_button_pressed() -> void:
	SceneManager.change_scene("res://ui/menus/credits.tscn")


func _on_settings_button_pressed() -> void:
	SceneManager.set_persistent_information("settings_tab", 0)
	SceneManager.change_scene("res://ui/menus/settings.tscn")


func _on_accessibility_settings_button_pressed() -> void:
	SceneManager.set_persistent_information("settings_tab", 2)
	SceneManager.change_scene("res://ui/menus/settings.tscn")


func _on_language_button_pressed() -> void:
	pass # Replace with function body.
