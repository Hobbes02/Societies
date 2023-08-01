extends NinePatchRect

@onready var label = $MarginContainer/Label
@onready var timer = $TalkTimer


func format_with_text(text: String) -> void:
	label.text = text
	
	await get_tree().process_frame
	
	size.x = label.size.x
	size.y = label.size.y + 4
