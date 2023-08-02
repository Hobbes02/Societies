extends NinePatchRect

@onready var label = $MarginContainer/Label
@onready var timer = $TalkTimer


func say(content: String, speaker: Node2D, y_padding: int = 32) -> void:
	align_with_node(speaker, y_padding)
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


func align_with_node(node: Node2D, y_pad: int = 32) -> void:
	self.pivot_offset = self.size  # moes pivot offset to bottom right
	self.position = node.position
	self.position.y -= y_pad


func format_with_text(text: String) -> void:
	label.text = text
	
	await get_tree().process_frame
	
	size.x = label.size.x + 1
	size.y = label.size.y + 4
