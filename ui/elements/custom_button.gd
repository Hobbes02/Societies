class_name CustomButton
extends Button

signal focused()

var locked: bool = false
var is_focused: bool = false


func _on_focus_entered():
	if is_focused: return
	
	focused.emit()
	
	text = "> " + text
	
	await get_tree().create_timer(0.1).timeout
	
	is_focused = true


func _on_focus_exited():
	if not is_focused: return
	
	is_focused = false
	
	text = text.lstrip("> ")


func change_text(to: String) -> void:
	text = ("> " if is_focused else "") + to
