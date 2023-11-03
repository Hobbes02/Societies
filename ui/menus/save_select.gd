extends Control

var last_focused_slot_button: CustomButton
var slot: Dictionary = {}

@onready var slot_1_button: Button = $VBoxContainer/Slot1Button
@onready var slot_2_button: Button = $VBoxContainer/Slot2Button
@onready var menus: Control = $".."
@onready var slot_name: Button = $SlotEditor/MarginContainer/VBoxContainer/SlotName
@onready var area_indicator: Label = $SlotEditor/MarginContainer/VBoxContainer/AreaIndicator
@onready var progress_indicator: ProgressBar = $SlotEditor/MarginContainer/VBoxContainer/Progress/ProgressIndicator
@onready var play_button: Button = $SlotEditor/MarginContainer/VBoxContainer/PlayButton
@onready var slot_editor: PanelContainer = $SlotEditor
@onready var slot_name_editor: ColorRect = $NameEditor
@onready var slot_new_name_enter: LineEdit = $NameEditor/PanelContainer/MarginContainer/VBoxContainer/NameEnter


func start() -> void:
	var slots: Dictionary = SaveManager.get_value("slots", {}, SaveManager.global_data)
	
	if len(slots.keys()) > 0:
		var slot_1_data = slots["0"]
		if slot_1_data != {}:
			slot_1_button.change_text(slot_1_data.get("name", "Empty Slot"))
	if len(slots.keys()) > 1:
		var slot_2_data = slots["1"]
		if slot_2_data != {}:
			slot_2_button.change_text(slot_2_data.get("name", "Empty Slot"))
	
	slot_1_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and slot_name_editor.visible:
		slot_name_editor.hide()
		slot_name.grab_focus()


func _on_back_button_pressed() -> void:
	hide()
	menus.title_screen.show()


func _on_slot_name_focused() -> void:
	slot_name.focus_neighbor_left = last_focused_slot_button.get_path()
	play_button.focus_neighbor_left = last_focused_slot_button.get_path()


func _on_slot_1_button_focused() -> void:
	slot = SaveManager.get_value("slots/0", {"id": "0"}, SaveManager.global_data)
	last_focused_slot_button = slot_1_button
	slot_editor.show()
	slot_name.text = slot.get("name", "Empty Slot")
	area_indicator.text = "Area: " + slot.get("area", "Start")
	progress_indicator.value = slot.get("progress", 0)


func _on_slot_2_button_focused() -> void:
	slot = SaveManager.get_value("slots/1", {"id": "1"}, SaveManager.global_data)
	last_focused_slot_button = slot_2_button
	slot_editor.show()
	slot_name.text = slot.get("name", "Empty Slot")
	area_indicator.text = "Area: " + slot.get("area", "Start")
	progress_indicator.value = slot.get("progress", 0)


func _on_back_button_focused() -> void:
	slot_editor.hide()


func _on_slot_name_pressed() -> void:
	slot_name_editor.show()
	slot_new_name_enter.clear()
	slot_new_name_enter.placeholder_text = slot.get("name", "")
	slot_new_name_enter.grab_focus()


func _on_name_enter_text_submitted(new_text: String) -> void:
	if not slot_name_editor.visible:
		return
	
	slot_name_editor.hide()
	slot_name.change_text(new_text)
	slot.name = new_text
	SaveManager.global_data.slots = SaveManager.global_data.get("slots", SaveManager.DEFAULT_GLOBAL_DATA.slots)
	SaveManager.global_data.slots[slot.id] = slot
	
	match slot.id:
		"0":
			slot_1_button.change_text(new_text)
		"1":
			slot_2_button.change_text(new_text)
	
	slot_name.grab_focus()


func _on_play_button_pressed() -> void:
	SaveManager.current_slot = int(slot.get("id", 0))
	SaveManager.save_data = await SaveManager.load_data(SaveManager.save_dir + SaveManager.file_name)
	SaveManager.just_loaded.emit()
	SceneManager.change_scene("res://world/world.tscn")
