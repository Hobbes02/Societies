extends Control

@onready var tabs: TabContainer = $TabContainer


func _on_back_button_pressed() -> void:
	SceneManager.change_scene("res://ui/menus/main_menu.tscn")
