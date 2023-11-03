extends Control

@onready var title_screen: Control = $TitleScreen
@onready var save_select: Control = $SaveSelect
@onready var play_button: Button = $TitleScreen/VBoxContainer/PlayButton


func _ready() -> void:
	play_button.grab_focus()


func _on_play_button_pressed() -> void:
	SceneManager.change_scene("res://world/world.tscn")


func _on_saves_button_pressed() -> void:
	title_screen.hide()
	save_select.show()
	save_select.start()


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_title_screen_visibility_changed() -> void:
	if title_screen and title_screen.visible:
		play_button.grab_focus()
