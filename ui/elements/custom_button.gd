class_name CustomButton
extends Button


func _on_focus_entered() -> void:
	text = "> " + text


func _on_focus_exited() -> void:
	text = text.lstrip("> ")


func _on_mouse_entered() -> void:
	grab_focus()
