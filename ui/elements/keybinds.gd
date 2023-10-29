extends Control

# when one action is changed, it will change the other one it's linked to as well
var linked_actions: Dictionary = {
	
}

var hidden_keybinds: Array = ["debug"]

var currently_rebinding: StringName = ""
var currently_rebinding_button: Button

@onready var action_name_template: Label = $MarginContainer/VBoxContainer/ScrollContainer/Columns/ActionNames/ActionNameTemplate
@onready var rebind_button_template: Button = $MarginContainer/VBoxContainer/ScrollContainer/Columns/RebindButtons/RebindButtonTemplate

@onready var action_names: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/Columns/ActionNames
@onready var rebind_buttons: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/Columns/RebindButtons


func _ready() -> void:
	action_name_template.hide()
	rebind_button_template.hide()
	
	load_keybind_visuals()
	
	SaveManager.about_to_save.connect(_about_to_save)
	SaveManager.just_loaded.connect(_just_loaded)


func _about_to_save() -> void:
	SaveManager.settings.keybinds = get_keybinds()


func _just_loaded() -> void:
	var loaded_keybinds = SaveManager.get_value("settings/keybinds", {})
	if loaded_keybinds != {}:
		load_keybinds(loaded_keybinds)


func get_keybinds() -> Dictionary:
	var keybinds: Dictionary = {}
	
	for action_name in InputMap.get_actions():
		var event: InputEvent = InputMap.action_get_events(action_name)[0]
		
		if not event is InputEventKey:
			continue
		
		var keycode: int = event.keycode
		
		keybinds[action_name] = keycode
	
	return keybinds


func load_keybinds(keybinds: Dictionary) -> void:
	for action_name in keybinds.keys():
		var keycode: int = keybinds[action_name]
		
		if not InputMap.has_action(StringName(action_name)):
			continue
		
		InputMap.action_erase_events(StringName(action_name))
		
		var event: InputEventKey = InputEventKey.new()
		event.pressed = true
		event.keycode = keycode
		
		InputMap.action_add_event(StringName(action_name), event)


func load_keybind_visuals() -> void:
	for label in action_names.get_children():
		label.queue_free()
	for button in rebind_buttons.get_children():
		button.queue_free()
	
	
	var keybinds = InputMap.get_actions()
	
	for action_name in keybinds:
		var event = InputMap.action_get_events(action_name)[0]
		
		if (not event is InputEventKey) or str(action_name).begins_with("ui") or str(action_name) in hidden_keybinds:
			continue
		
		var keycode = event.keycode if event.keycode != 0 else event.physical_keycode
		
		var name_label: Label = action_name_template.duplicate()
		name_label.text = str(action_name).replace("_", " ").capitalize()
		action_names.add_child(name_label)
		name_label.show()
		
		var rebind_button: Button = rebind_button_template.duplicate()
		rebind_button.text = OS.get_keycode_string(keycode)
		rebind_buttons.add_child(rebind_button)
		rebind_button.name = action_name
		rebind_button.show()
		
		rebind_button.pressed.connect(_on_key_rebind_request.bind(action_name, rebind_button))


func _on_key_rebind_request(action_name: StringName, button: Button) -> void:
	if currently_rebinding == "":
		currently_rebinding = action_name
		currently_rebinding_button = button
		button.text = ">" + button.text + "<"
	elif currently_rebinding == action_name:
		button.text = button.text.replace("<", "").replace(">", "")
		currently_rebinding = ""


func _input(event: InputEvent) -> void:
	if currently_rebinding != "" and event is InputEventKey and event.is_pressed() and currently_rebinding_button != null:
		var keycode_name: String = OS.get_keycode_string(event.keycode)
		currently_rebinding_button.text = keycode_name
		
		InputMap.action_erase_events(StringName(currently_rebinding))
		InputMap.action_add_event(StringName(currently_rebinding), event)
		
		if currently_rebinding in linked_actions.keys():
			InputMap.action_erase_events(StringName(linked_actions[currently_rebinding]))
			InputMap.action_add_event(StringName(linked_actions[currently_rebinding]), event)
		
		
		for button in rebind_buttons.get_children():
			if button.text == keycode_name and button != currently_rebinding_button:
				button.text = "[INVALID]"
				InputMap.action_erase_events(StringName(button.name))
		
		currently_rebinding = ""
