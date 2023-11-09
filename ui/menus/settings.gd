extends Control

enum VOLUME_TYPES {
	MASTER = 0, 
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
@onready var volume_display_label: Label = $VolumeChangeListener/PanelContainer/MarginContainer/Label


func _ready() -> void:
	first_time_load_keybinds()
	
	SaveManager.about_to_save.connect(_about_to_save)


func start() -> void:
	load_keybinds()
	sound_settings_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("stop_listening_for_key_events") and currently_rebinding != []:
		currently_rebinding = []
		key_listener.hide()
		keybind_settings_button.grab_focus()
	elif event is InputEventKey and currently_rebinding != []:
		change_action_event(currently_rebinding[0], event.keycode if event.keycode != 0 else event.physical_keycode)
		keybinds[currently_rebinding[0]] = event.keycode
		currently_rebinding = []
		key_listener.hide()
		keybind_settings_button.grab_focus()
		load_keybinds()
	elif event.is_action_pressed("ui_left") and volume_change_listener.visible:
		# TODO: decrease volume in that type
		match currently_changing_volume:
			VOLUME_TYPES.MASTER:
				pass
			VOLUME_TYPES.SFX:
				pass
			VOLUME_TYPES.MUSIC:
				pass
			VOLUME_TYPES.NONE:
				return
	elif event.is_action_pressed("ui_right") and volume_change_listener.visible:
		# TODO: increase volume in that type
		match currently_changing_volume:
			VOLUME_TYPES.MASTER:
				pass
			VOLUME_TYPES.SFX:
				pass
			VOLUME_TYPES.MUSIC:
				pass
			VOLUME_TYPES.NONE:
				return
	elif event.is_action_pressed("ui_cancel") and volume_change_listener.visible:
		volume_change_listener.hide()
		currently_changing_volume = VOLUME_TYPES.NONE
		sound_settings_button.grab_focus()


func _about_to_save() -> void:
	if keybinds == {}:
		return
	SaveManager.global_data.settings = SaveManager.global_data.get("settings", SaveManager.DEFAULT_GLOBAL_DATA.settings)
	SaveManager.global_data.settings.keybinds = keybinds


# SOUND

func _on_master_volume_button_pressed() -> void:
	volume_display_label.text = "Changing Master Volume\n\n" + "[volume]" + "%"
	currently_changing_volume = VOLUME_TYPES.MASTER
	volume_change_listener.show()
	get_viewport().gui_release_focus()


func _on_sfx_volume_button_pressed() -> void:
	volume_display_label.text = "Changing SFX Volume\n\n" + "[volume]" + "%"
	currently_changing_volume = VOLUME_TYPES.SFX
	volume_change_listener.show()
	get_viewport().gui_release_focus()


func _on_music_volume_button_pressed() -> void:
	volume_display_label.text = "Changing Music Volume\n\n" + "[volume]" + "%"
	currently_changing_volume = VOLUME_TYPES.MUSIC
	volume_change_listener.show()
	get_viewport().gui_release_focus()


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
			$KeybindSettings
		], 
		1.0, 
		0.0
	)
	hide()
	menus.title_screen.show()


func first_time_load_keybinds() -> void:
	if keybinds == {}:
		return
	
	for bind in editable_keybinds:
		if not InputMap.has_action(bind):
			continue
		
		keybinds[bind] = get_action_keycode(bind)
	_about_to_save()


func load_keybinds() -> void:
	keybind_template.show()
	keybinds = SaveManager.global_data.get("settings", {"keybinds": {}}).get("keybinds", keybinds)
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


func _on_keybind_settings_button_focused() -> void:
	keybind_settings.show()
	sound_settings.hide()


func _on_accessibility_settings_button_focused() -> void:
	keybind_settings.hide()
	sound_settings.hide()


func _on_back_button_focused() -> void:
	keybind_settings.hide()
	sound_settings.hide()

