extends CanvasLayer

@onready var pause_menu: Control = $PauseMenu
@onready var resume_button: CustomButton = $PauseMenu/CenterContainer/VBoxContainer/ResumeButton
@onready var settings_button: CustomButton = $PauseMenu/CenterContainer/VBoxContainer/SettingsButton
@onready var quit_button: CustomButton = $PauseMenu/CenterContainer/VBoxContainer/QuitButton


func _input(event: InputEvent) -> void:
	if event.is_action_released("pause"):
		pause_menu.visible = not pause_menu.visible
		SceneManager.pause("game", pause_menu.visible)
		resume_button.grab_focus()


func _on_resume_button_pressed() -> void:
	pause_menu.hide()
	SceneManager.pause("game", false)


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	SaveManager._notification(NOTIFICATION_WM_CLOSE_REQUEST)
