extends CanvasLayer

@onready var pause_menu: CenterContainer = $Control/PauseMenu
@onready var blur: ColorRect = $Control/Blur

@onready var notification_title: Label = $Control/Notification/MarginContainer/VBoxContainer/Title
@onready var notification_info: Label = $Control/Notification/MarginContainer/VBoxContainer/Info
@onready var notification: PanelContainer = $Control/Notification
@onready var notification_player: AnimationPlayer = $Control/Notification/NotificationPlayer



func show_notification(title: String, info: String, wait_time: int = 4) -> void:
	notification_title.text = title
	notification_info.text = info
	notification.show()
	notification_player.play("pop_in")
	await get_tree().create_timer(wait_time).timeout
	notification_player.play("pop_out")
	await notification_player.animation_finished
	notification.hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and SceneManager.active_scene == "Scenes/World":
		blur.visible = not blur.visible
		pause_menu.visible = blur.visible
		
		SceneManager.pause("game", blur.visible)
		SaveManager.save()


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
