extends Control

@onready var tabs: TabContainer = $TabContainer



func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/menus/main_menu.tscn")
