extends Button

signal key_pressed(keycode,event)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		emit_signal("key_pressed", event.physical_keycode, event)
		print(event.keycode)
	elif event is InputEventMouseButton:
		emit_signal("key_pressed", event.button_index, event)
