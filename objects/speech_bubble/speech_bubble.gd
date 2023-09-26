extends Control

@export var continue_action: String = "continue_dialogue"

var waiting_to_continue: bool = false
var response_nodes: Array = []

var resource: DialogueResource
var dialogue_line: DialogueLine :
	set(next_dialogue_line):
		for response in response_nodes:
			response_container.remove_child(response)
			response.queue_free()
		response_nodes.clear()
		
		dialogue_line = next_dialogue_line
		
		if dialogue_line.responses.size() > 0:
			for i in range(len(dialogue_line.responses)):
				var response = dialogue_line.responses[i]
				var response_node: RichTextLabel = response_template.duplicate(0)
				response_node.name = "Response" + str(i)
				if not response.is_allowed:
					response_node.name += "Disallowed"
					response_node.self_modulate.a = 0.8
				response_nodes.append(response_node)
				response_node.text = response.text
				response_container.add_child(response_node)
				response_node.hide()
		
		dialogue_label.dialogue_line = dialogue_line
		await get_tree().process_frame
		
		dialogue_label.type_out()
		await dialogue_label.finished_typing
		
		if dialogue_line.responses.size() > 0:
			for i in response_nodes:
				i.show()
			configure_menu()
		
		waiting_to_continue = true


@onready var dialogue_label: DialogueLabel = $MarginContainer/VBoxContainer/DialogueLabel
@onready var response_template: RichTextLabel = $ReponseTemplate
@onready var response_container: VBoxContainer = $MarginContainer/VBoxContainer


func _ready() -> void:
	response_template.hide()


func start(dialogue_resource: DialogueResource, title: String) -> void:
	resource = dialogue_resource
	dialogue_line = await resource.get_next_dialogue_line(title)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(continue_action) and waiting_to_continue and dialogue_line.responses.size() < 1:
		waiting_to_continue = false
		var next_line = await resource.get_next_dialogue_line(dialogue_line.next_id)
		if next_line:
			dialogue_line = next_line
		else:
			hide()


func _on_response_gui_input(event: InputEvent, response: DialogueResponse) -> void:
	if event.is_action_pressed(continue_action) and waiting_to_continue:
		waiting_to_continue = false
		var next_line = await resource.get_next_dialogue_line(response.next_id)
		if next_line:
			dialogue_line = next_line
		else:
			hide()
		get_viewport().set_input_as_handled()


func get_responses() -> Array:
	var items: Array = []
	for child in response_container.get_children():
		if "Disallowed" in child.name or child is DialogueLabel: continue
		items.append(child)

	return items


func configure_menu() -> void:
	focus_mode = Control.FOCUS_NONE
	
	var items = get_responses()
	for i in items.size():
		var item: Control = items[i]
		
		item.focus_mode = Control.FOCUS_ALL
		
		item.focus_neighbor_left = item.get_path()
		item.focus_neighbor_right = item.get_path()
		
		if i == 0:
			item.focus_neighbor_top = item.get_path()
			item.focus_previous = item.get_path()
		else:
			item.focus_neighbor_top = items[i - 1].get_path()
			item.focus_previous = items[i - 1].get_path()
		
		if i == items.size() - 1:
			item.focus_neighbor_bottom = item.get_path()
			item.focus_next = item.get_path()
		else:
			item.focus_neighbor_bottom = items[i + 1].get_path()
			item.focus_next = items[i + 1].get_path()
		
		if not item.gui_input.is_connected(_on_response_gui_input):
			item.gui_input.connect(_on_response_gui_input.bind(dialogue_line.responses[i]))
	
	items[0].grab_focus()
