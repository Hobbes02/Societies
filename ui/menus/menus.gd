extends Control

@onready var title_screen: Control = $TitleScreen
@onready var save_select: Control = $SaveSelect
@onready var play_button: Button = $TitleScreen/VBoxContainer/PlayButton
@onready var settings: Control = $Settings


func _ready() -> void:
	SceneManager.pause("game", true)
	
	var last_played_slot = SaveManager.settings_data.get("last_played_slot", -1)
	if last_played_slot != -1 and len(SaveManager.slots) > last_played_slot and SaveManager.slots[last_played_slot].get("name", "Empty Slot") not in ["", "Empty Slot"]:
		play_button.change_text("Play: " + SaveManager.slots[last_played_slot].get("name", "Empty Slot"))
	else:
		play_button.change_text("New Game")
	play_button.grab_focus()


func _on_play_button_pressed() -> void:
	var slot_to_play: int = SaveManager.settings_data.get("last_played_slot", 0)
	SaveManager.current_save_slot = slot_to_play
	
	if slot_to_play == -1 or len(SaveManager.slots) <= slot_to_play or SaveManager.slots[slot_to_play].get("name", "Empty Slot") != "Empty Slot":
		if slot_to_play == -1:
			if len(SaveManager.slots) > 1:
				slot_to_play = 1
			else:
				slot_to_play = 0
		SaveManager.current_save_slot = slot_to_play
		SaveManager.save_slot_data(
			{
				"name": "Played Slot " + str(slot_to_play + 1), 
				"area": "Start", 
				"progress": 0
			}, 
			slot_to_play
		)
		SaveManager.settings_data.last_played_slot = slot_to_play
	
	SaveManager.load_game_data()
	
	var scene: String = "res://" + SaveManager.save_data.get("scene_data", {}).get("current_scene", "world/world") + ".tscn"
	
	SceneManager.change_scene(scene)


func _on_saves_button_pressed() -> void:
	await fade(
		[
			$TitleScreen/Logo, 
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
			$TitleScreen/Logo, 
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
		_ready()
		await fade(
			[
				$TitleScreen/Logo, 
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
