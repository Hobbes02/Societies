extends NinePatchRect

@onready var label = $MarginContainer/Label
@onready var timer = $TalkTimer


func say(content: String, speaker: String) -> void:
	label.hide()
	format_with_text(content)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	label.visible_characters = 0
	label.show()
	for letter in content:
		label.visible_characters += 1
		timer.start()
		await timer.timeout
	label.visible_characters = -1


func format_with_text(text: String) -> void:
	label.text = text
	
	await get_tree().process_frame
	
	size.x = label.size.x + 1
	size.y = label.size.y + 4
