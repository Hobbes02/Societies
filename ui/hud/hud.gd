extends CanvasLayer

@onready var pause_menu: CenterContainer = $Control/PauseMenu
@onready var blur: ColorRect = $Control/Blur



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and SceneManager.active_scene == "Scenes/World":
		blur.visible = not blur.visible
		pause_menu.visible = blur.visible
		
		SceneManager.pause("game", blur.visible)


func _on_resume_button_pressed() -> void:
	blur.hide()
	pause_menu.hide()
	
	SceneManager.pause("game", false)


func _on_settings_button_pressed() -> void:
	_on_resume_button_pressed()
	SceneManager.change_scene("res://ui/menus/settings.tscn")


func _on_quit_button_pressed() -> void:
	_on_resume_button_pressed()
	SceneManager.change_scene("res://ui/menus/main_menu.tscn")
