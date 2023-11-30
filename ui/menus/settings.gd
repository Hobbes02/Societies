extends Control

enum VOLUME_TYPES {
	MAIN = 0, 
	SFX = 1, 
	MUSIC = 2, 
	NONE = 3
}

var keybinds: Dictionary = {}
var editable_keybinds: Array[String] = [
	"interact", 
	"walk_left", 
	"walk_right", 
	"jump", 
	"crawl", 
	"sprint", 
	"pause", 
	"ui_left", 
	"ui_right", 
	"ui_up", 
	"ui_down", 
	"ui_accept", 
	"ui_cancel"
]

var currently_rebinding: Array = []

var currently_changing_volume: VOLUME_TYPES = VOLUME_TYPES.NONE

var master_bus: int = AudioServer.get_bus_index("Master")
var sfx_bus: int = AudioServer.get_bus_index("SFX")
var music_bus: int = AudioServer.get_bus_index("Music")

@onready var keybind_settings: PanelContainer = $KeybindSettings
@onready var keybind_template: CustomButton = $KeybindSettings/MarginContainer/ScrollContainer/VBoxContainer/KeybindTemplate
@onready var keybinds_container: VBoxContainer = $KeybindSettings/MarginContainer/ScrollContainer/VBoxContainer
@onready var keybind_settings_button: Button = $VBoxContainer/KeybindSettingsButton
@onready var key_listener: ColorRect = $KeyListener
@onready var sound_settings_button: Button = $VBoxContainer/SoundSettingsButton
@onready var menus: Control = $".."
@onready var start_listening_wait_timer: Timer = $StartListeningWaitTimer
@onready var sound_settings: PanelContainer = $SoundSettings
@onready var volume_change_listener: ColorRect = $VolumeChangeListener
@onready var volume_display_label: Label = $VolumeChangeListener/PanelContainer/MarginContainer/VBoxContainer/Label
@onready var accessibility_settings: PanelContainer = $AccessibilitySettings
@onready var volume_slider: HSlider = $VolumeChangeListener/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VolumeSlider
@onready var volume_value_display: Label = $VolumeChangeListener/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VolumeValueDisplay

func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	first_time_load_keybinds()
	
	SaveManager.global_data.settings = SaveManager.global_data.get("settings", SaveManager.DEFAULT_GLOBAL_DATA.settings)
	SaveManager.global_data.settings.volume = SaveManager.global_data.settings.get("volume", SaveManager.DEFAULT_GLOBAL_DATA.settings.volume)
	
	AudioServer.set_bus_volume_db(master_bus, SaveManager.global_data.settings.volume.get("Master", 0))
	AudioServer.set_bus_volume_db(music_bus, SaveManager.global_data.settings.volume.get("Music", 0))
	AudioServer.set_bus_volume_db(sfx_bus, SaveManager.global_data.settings.volume.get("SFX", 0))
	
	SaveManager.about_to_save.connect(_about_to_save)


func start() -> void:
	load_keybinds()
	sound_settings_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("stop_listening_for_key_events") and currently_rebinding != []:
		currently_rebinding = []
		key_listener.hide()
		keybind_settings_button.grab_focus()
	elif event is InputEventKey and currently_rebinding != [] and event.is_released():
		change_action_event(currently_rebinding[0], event.keycode if event.keycode != 0 else event.physical_keycode)
		keybinds[currently_rebinding[0]] = event.keycode
		currently_rebinding = []
		key_listener.hide()
		keybind_settings_button.grab_focus()
		load_keybinds()
	elif volume_change_listener.visible:
		match currently_changing_volume:
			VOLUME_TYPES.MAIN:
				AudioServer.set_bus_volume_db(master_bus, linear_to_db(volume_slider.value))
				volume_value_display.text = str(volume_slider.value * 100)
			VOLUME_TYPES.SFX:
				AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(volume_slider.value))
				volume_value_display.text = str(volume_slider.value * 100)
			VOLUME_TYPES.MUSIC:
				AudioServer.set_bus_volume_db(music_bus, linear_to_db(volume_slider.value))
				volume_value_display.text = str(volume_slider.value * 100)
			VOLUME_TYPES.NONE:
				return


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and volume_change_listener.visible:
		volume_change_listener.hide()
		currently_changing_volume = VOLUME_TYPES.NONE
		sound_settings_button.grab_focus()


func _about_to_save(layer: String) -> void:
	SaveManager.global_data.settings = SaveManager.global_data.get("settings", SaveManager.DEFAULT_GLOBAL_DATA.settings)
	if keybinds != {}:
		SaveManager.global_data.settings.keybinds = keybinds
	
	SaveManager.global_data.settings.volume = SaveManager.global_data.settings.get("volume", SaveManager.DEFAULT_GLOBAL_DATA.settings.volume)
	
	SaveManager.global_data.settings.volume.Master = AudioServer.get_bus_volume_db(master_bus)
	SaveManager.global_data.settings.volume.SFX = AudioServer.get_bus_volume_db(sfx_bus)
	SaveManager.global_data.settings.volume.Music = AudioServer.get_bus_volume_db(music_bus)


# SOUND

func _on_master_volume_button_pressed() -> void:
	await get_tree().process_frame
	volume_display_label.text = "Changing Main Volume"
	volume_slider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(master_bus)))
	volume_value_display.text = str(volume_slider.value * 100)
	currently_changing_volume = VOLUME_TYPES.MAIN
	volume_change_listener.show()
	volume_slider.grab_focus()


func _on_sfx_volume_button_pressed() -> void:
	await get_tree().process_frame
	volume_display_label.text = "Changing SFX Volume"
	volume_slider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(sfx_bus)))
	volume_value_display.text = str(volume_slider.value * 100)
	currently_changing_volume = VOLUME_TYPES.SFX
	volume_change_listener.show()
	volume_slider.grab_focus()


func _on_music_volume_button_pressed() -> void:
	await get_tree().process_frame
	volume_display_label.text = "Changing Music Volume"
	volume_slider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(music_bus)))
	volume_value_display.text = str(volume_slider.value * 100)
	currently_changing_volume = VOLUME_TYPES.MUSIC
	volume_change_listener.show()
	volume_slider.grab_focus()


# KEYBINDS

func _on_keybind_button_pressed(action_name: String, keycode: int, button: CustomButton) -> void:
	key_listener.show()
	key_listener.grab_focus()
	
	await get_tree().create_timer(0.8).timeout
	
	currently_rebinding = [action_name, keycode]


func _on_back_button_pressed() -> void:
	await menus.fade(
		[
			$VBoxContainer/TitleLabel, 
			$VBoxContainer/SoundSettingsButton, 
			$VBoxContainer/KeybindSettingsButton, 
			$VBoxContainer/AccessibilitySettingsButton, 
			$VBoxContainer/BackButton, 
			$SoundSettings, 
			$KeybindSettings, 
			$AccessibilitySettings
		], 
		1.0, 
		0.0
	)
	hide()
	menus.title_screen.show()


func first_time_load_keybinds() -> void:
	keybinds = SaveManager.global_data.get("settings", {"keybinds": {}}).get("keybinds", keybinds)
	if keybinds == {}:
		for bind in editable_keybinds:
			if not InputMap.has_action(bind):
				continue
			
			keybinds[bind] = get_action_keycode(bind)
		_about_to_save("")
	
	for bind in keybinds.keys():
		change_action_event(bind, keybinds[bind])


func load_keybinds() -> void:
	keybind_template.show()
	var keybind_nodes: Array[CustomButton] = []
	
	
	for node in keybinds_container.get_children():
		if node.name.begins_with("Keybind##"):
			node.queue_free()
	
	
	for bind in editable_keybinds:
		if bind not in keybinds.keys():
			continue
		
		var keybind_node: CustomButton = keybind_template.duplicate()
		keybind_node.text = bind.replace("_", " ").capitalize() + ": " + OS.get_keycode_string(keybinds[bind])
		keybind_node.focus_neighbor_left = keybind_settings_button.get_path()
		keybind_node.name = "Keybind## " + bind
		keybinds_container.add_child(keybind_node, true)
		keybind_node.pressed.connect(_on_keybind_button_pressed.bind(bind, keybinds[bind], keybind_node))
		
		keybind_nodes.append(keybind_node)
		
		if bind == editable_keybinds[0]:  # if it's the first one
			keybind_settings_button.focus_neighbor_right = keybind_node.get_path()
		
		change_action_event(bind, keybinds[bind])
	
	keybind_template.hide()
	
	
	# Set up focus
	for i in range(len(keybind_nodes)):
		var node = keybind_nodes[i]
		
		if i != len(keybind_nodes) - 1:
			node.focus_neighbor_bottom = keybind_nodes[i + 1].get_path()
			node.focus_next = keybind_nodes[i + 1].get_path()
		else:
			node.focus_neighbor_bottom = node.get_path()
			node.focus_next = node.get_path()
		
		if i != 0:
			node.focus_neighbor_top = keybind_nodes[i - 1].get_path()
			node.focus_previous = keybind_nodes[i - 1].get_path()
		else:
			node.focus_neighbor_top = node.get_path()
			node.focus_previous = node.get_path()


func change_action_event(action_name: String, event_code: int) -> void:
	if not InputMap.has_action(action_name):
		return
	
	InputMap.action_erase_events(action_name)
	
	var event = InputEventKey.new()
	event.keycode = event_code
	event.physical_keycode = event_code
	
	InputMap.action_add_event(action_name, event)


func get_action_keycode(action_name: String) -> int:
	if not InputMap.has_action(action_name):
		return -1
	
	var event = InputMap.action_get_events(action_name)[0]
	
	if not event is InputEventKey:
		return -1
	
	return event.keycode if event.keycode != 0 else event.physical_keycode


# GLOBAL

func _on_sound_settings_button_focused() -> void:
	keybind_settings.hide()
	sound_settings.show()
	accessibility_settings.hide()


func _on_keybind_settings_button_focused() -> void:
	keybind_settings.show()
	sound_settings.hide()
	accessibility_settings.hide()


func _on_accessibility_settings_button_focused() -> void:
	keybind_settings.hide()
	sound_settings.hide()
	accessibility_settings.show()


func _on_back_button_focused() -> void:
	keybind_settings.hide()
	sound_settings.hide()
	accessibility_settings.hide()


func _on_volume_slider_value_changed(value: float) -> void:
	volume_value_display.text = str(value * 100)
	var bus_idx: int = currently_changing_volume
	
	if bus_idx != VOLUME_TYPES.NONE:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
