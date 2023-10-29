extends Control


func _ready() -> void:
	$CenterContainer/VBoxContainer/PlayButton.grab_focus()


func _on_play_button_pressed() -> void:
	SceneManager.change_scene("res://world/world.tscn")
