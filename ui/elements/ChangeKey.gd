extends Button

signal key_pressed(event_name,event_code)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		emit_signal("key_pressed",event.as_text(),event.physical_keycode)
		print(event.keycode)
	elif event is InputEventMouseButton:
		emit_signal("key_pressed",event.as_text(),event.button_index)
