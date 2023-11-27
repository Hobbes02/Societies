extends Control

var slot: Dictionary = {}

@onready var name_changer: PanelContainer = $NameChanger
@onready var blur: ColorRect = $Blur
@onready var new_name_enter: LineEdit = $NameChanger/MarginContainer/VBoxContainer/NewNameEnter
@onready var change_name_button: Button = $VBoxContainer/ChangeNameButton


func start() -> void:
	$VBoxContainer/PlaySlotButton.grab_focus()


func _on_play_slot_button_pressed() -> void:
	SaveManager.current_slot = slot.get("id", 0)
	await get_tree().process_frame
	SaveManager.save_data = await SaveManager.load_data(SaveManager.save_dir + SaveManager.file_name)
	SceneManager.change_scene("res://world/world.tscn")


func _on_change_name_button_pressed() -> void:
	name_changer.show()
	blur.show()
	new_name_enter.placeholder_text = slot.get("name", "")
	new_name_enter.grab_focus()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and name_changer.visible:
		name_changer.hide()
		blur.hide()
		change_name_button.grab_focus()


func _on_new_name_enter_text_submitted(new_text: String) -> void:
	name_changer.hide()
	blur.hide()
	new_name_enter.clear()
	slot.name = new_text
	SaveManager.global_data.slots[slot.get("id", 0)] = slot
	change_name_button.grab_focus()


func _on_clear_button_pressed() -> void:
	slot = {}
	SaveManager.global_data.slots[slot.get("id", 0)] = slot


func _on_back_button_pressed() -> void:
	pass # Replace with function body.
