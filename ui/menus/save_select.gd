extends Control

var last_focused_slot_button: CustomButton
var currently_editing_slot: int = 0

@onready var slot_1_button: Button = $VBoxContainer/Slot1Button
@onready var slot_2_button: Button = $VBoxContainer/Slot2Button
@onready var menus: Control = $".."
@onready var slot_name: Button = $SlotEditor/MarginContainer/VBoxContainer/SlotName
@onready var area_indicator: Label = $SlotEditor/MarginContainer/VBoxContainer/AreaIndicator
@onready var progress_indicator: ProgressBar = $SlotEditor/MarginContainer/VBoxContainer/Progress/ProgressIndicator
@onready var play_button: Button = $SlotEditor/MarginContainer/VBoxContainer/PlayButton
@onready var clear_button: Button = $SlotEditor/MarginContainer/VBoxContainer/ClearButton
@onready var slot_editor: PanelContainer = $SlotEditor
@onready var slot_name_editor: ColorRect = $NameEditor
@onready var slot_new_name_enter: LineEdit = $NameEditor/PanelContainer/MarginContainer/VBoxContainer/NameEnter
@onready var clear_confirm: ColorRect = $ClearConfirm


func start() -> void:
	
	print(SaveManager.slots)
	
	if len(SaveManager.slots) >= 1:
		slot_1_button.change_text(SaveManager.slots[0].get("name"))
	if len(SaveManager.slots) >= 2:
		slot_2_button.change_text(SaveManager.slots[1].get("name"))
	
	slot_1_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if slot_name_editor.visible:
			slot_name_editor.hide()
			slot_name.grab_focus()
		elif clear_confirm.visible:
			clear_confirm.hide()
			clear_button.grab_focus()
	elif event.is_action_pressed("ui_accept") and clear_confirm.visible:
		SaveManager.save_slot_data({"name": "Empty Slot", "area": "Start", "progress": 0}, currently_editing_slot)
		last_focused_slot_button.change_text("Empty Slot")
		slot_name.change_text("Empty Slot")
		
		var dir = DirAccess.open("user://saves")
		dir.remove("user://saves/slot_" + str(currently_editing_slot) + ".societies")
		
		play_button.hide()
		clear_button.hide()
		slot_name.text = "Empty Slot"
		
		clear_confirm.hide()
		if SaveManager.settings_data.get("last_played_slot", -1) == currently_editing_slot:
			SaveManager.settings_data.last_played_slot = -1
		
		if SaveManager.current_save_slot == currently_editing_slot:
			SaveManager.save_data = SaveManager.DEFAULT_SAVE_DATA.duplicate(true)
		
		last_focused_slot_button.grab_focus()


func _on_back_button_pressed() -> void:
	await menus.fade(
		[
			$VBoxContainer/TitleLabel, 
			$VBoxContainer/Slot1Button, 
			$VBoxContainer/Slot2Button, 
			$VBoxContainer/BackButton
		], 
		1.0, 
		0.0
	)
	hide()
	menus.title_screen.show()


func _on_slot_name_focused() -> void:
	slot_name.focus_neighbor_left = last_focused_slot_button.get_path()
	play_button.focus_neighbor_left = last_focused_slot_button.get_path()
	clear_button.focus_neighbor_left = last_focused_slot_button.get_path()


func _on_slot_1_button_focused() -> void:
	currently_editing_slot = 0
	var slot: Dictionary
	if len(SaveManager.slots) >= 1:
		slot = SaveManager.slots[0]
	last_focused_slot_button = slot_1_button
	slot_editor.show()
	slot_name.text = slot.get("name", "Empty Slot")
	area_indicator.text = "Area: " + slot.get("area", "Start")
	progress_indicator.value = slot.get("progress", 0)
	
	if slot.get("name", "Empty Slot") == "Empty Slot":
		clear_button.hide()
		play_button.hide()
	else:
		clear_button.show()
		play_button.show()


func _on_slot_2_button_focused() -> void:
	currently_editing_slot = 1
	var slot: Dictionary
	if len(SaveManager.slots) >= 2:
		slot = SaveManager.slots[1]
	last_focused_slot_button = slot_2_button
	slot_editor.show()
	slot_name.text = slot.get("name", "Empty Slot")
	area_indicator.text = "Area: " + slot.get("area", "Start")
	progress_indicator.value = slot.get("progress", 0)
	
	if slot.get("name", "Empty Slot") == "Empty Slot":
		clear_button.hide()
		play_button.hide()
	else:
		clear_button.show()
		play_button.show()


func _on_back_button_focused() -> void:
	slot_editor.hide()


func _on_slot_name_pressed() -> void:
	slot_name_editor.show()
	slot_new_name_enter.clear()
	slot_new_name_enter.grab_focus()


func _on_name_enter_text_submitted(new_text: String) -> void:
	if not slot_name_editor.visible:
		return
	
	slot_name_editor.hide()
	slot_name.change_text(new_text)
	
	var new_slot_data: Dictionary = {"name": new_text, "area": "Start", "progress": 0}
	if len(SaveManager.slots) >= currently_editing_slot + 1:
		new_slot_data.area = SaveManager.slots[currently_editing_slot].get("area", "Start")
		new_slot_data.progress = SaveManager.slots[currently_editing_slot].get("progress", 0)
	SaveManager.save_slot_data(new_slot_data, currently_editing_slot)
	
	last_focused_slot_button.change_text(new_text)
	
	slot_name.grab_focus()
	clear_button.show()
	play_button.show()


func _on_play_button_pressed() -> void:
	SaveManager.settings_data.last_played_slot = currently_editing_slot
	SaveManager.current_save_slot = currently_editing_slot
	
	SaveManager.load_game_data()
	
	var scene: String = "res://" + SaveManager.save_data.get("scene_data", {}).get("current_scene", "world/world") + ".tscn"
	
	SceneManager.change_scene(scene)


func _on_clear_button_pressed() -> void:
	clear_confirm.show()
	clear_confirm.grab_focus()
