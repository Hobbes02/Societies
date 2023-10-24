extends Control


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://world/world_area.tscn")


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/menus/credits.tscn")


func _on_settings_button_pressed() -> void:
	Settings.tab = 0
	get_tree().change_scene_to_file("res://ui/menus/settings.tscn")


func _on_accessibility_settings_button_pressed() -> void:
	Settings.tab = 2
	get_tree().change_scene_to_file("res://ui/menus/settings.tscn")


func _on_language_button_pressed() -> void:
	pass # Replace with function body.
