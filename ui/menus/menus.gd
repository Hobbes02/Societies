extends Control

@onready var title_screen: Control = $TitleScreen
@onready var save_select: Control = $SaveSelect
@onready var play_button: Button = $TitleScreen/VBoxContainer/PlayButton
@onready var settings: Control = $Settings


func _ready() -> void:
	SceneManager.pause("game", true)
	
	var last_played_slot = SaveManager.global_data.get("slots", {}).get("last_played_slot", "none")
	if last_played_slot != "none":
		play_button.change_text("Play (" + SaveManager.global_data.get("slots", {}).get(last_played_slot, {}).get("name", "") + ")")
	else:
		play_button.change_text("Play")
	play_button.grab_focus()


func _on_play_button_pressed() -> void:
	var slot_to_play: String = SaveManager.global_data.get("slots", {}).get("last_played_slot", "none")
	SaveManager.current_slot = int(slot_to_play)
	SaveManager.save_data = await SaveManager.load_data(SaveManager.save_dir + SaveManager.file_name)
	SaveManager.just_loaded.emit()
	
	SceneManager.change_scene("res://world/world.tscn")


func _on_saves_button_pressed() -> void:
	await fade(
		[
			$TitleScreen/VBoxContainer/TitleLabel, 
			$TitleScreen/VBoxContainer/PlayButton, 
			$TitleScreen/VBoxContainer/SavesButton, 
			$TitleScreen/VBoxContainer/SettingsButton
		], 
		1.0, 
		0.0
	)
	title_screen.hide()
	save_select.show()
	save_select.start()
	await fade(
		[
			$SaveSelect/VBoxContainer/TitleLabel, 
			$SaveSelect/VBoxContainer/Slot1Button, 
			$SaveSelect/VBoxContainer/Slot2Button, 
			$SaveSelect/VBoxContainer/BackButton, 
			$SaveSelect/SlotEditor
		],
		0.0, 
		1.0
	)


func _on_settings_button_pressed() -> void:
	await fade(
		[
			$TitleScreen/VBoxContainer/TitleLabel, 
			$TitleScreen/VBoxContainer/PlayButton, 
			$TitleScreen/VBoxContainer/SavesButton, 
			$TitleScreen/VBoxContainer/SettingsButton
		], 
		1.0, 
		0.0
	)
	title_screen.hide()
	settings.show()
	settings.start()
	await fade(
		[
			$Settings/VBoxContainer/TitleLabel, 
			$Settings/VBoxContainer/SoundSettingsButton, 
			$Settings/VBoxContainer/KeybindSettingsButton, 
			$Settings/VBoxContainer/AccessibilitySettingsButton, 
			$Settings/VBoxContainer/BackButton, 
			$Settings/SoundSettings, 
			$Settings/KeybindSettings, 
			$Settings/AccessibilitySettings
		],
		0.0, 
		1.0
	)


func _on_title_screen_visibility_changed() -> void:
	if title_screen and title_screen.visible:
		var last_played_slot = SaveManager.global_data.get("slots", {}).get("last_played_slot", "none")
		if last_played_slot != "none":
			play_button.change_text("Play (" + SaveManager.global_data.get("slots", {}).get(last_played_slot, {}).get("name", "") + ")")
		else:
			play_button.change_text("Play")
		play_button.grab_focus()
		await fade(
			[
				$TitleScreen/VBoxContainer/TitleLabel, 
				$TitleScreen/VBoxContainer/PlayButton, 
				$TitleScreen/VBoxContainer/SavesButton, 
				$TitleScreen/VBoxContainer/SettingsButton
			], 
			0.0, 
			1.0
		)


func fade(nodes: Array, from: float, to: float) -> void:
	for node in nodes:
		node.modulate.a = from
	
	for node in nodes:
		var t = get_tree().create_tween()
		t.tween_property(node, "modulate", Color(1, 1, 1, to), 0.6)
		await get_tree().create_timer(0.2).timeout
	await get_tree().create_timer(0.4).timeout
