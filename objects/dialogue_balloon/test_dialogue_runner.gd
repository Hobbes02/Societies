extends BaseDialogueTestScene

const Balloon = preload("res://objects/speech_bubble/speech_bubble.tscn")

func _ready() -> void:
	var balloon: Node = Balloon.instantiate()
	add_child(balloon)
	
	print("====================================")
	print("RUNNING DIALOGUE TEST")
	print("TITLE: " + title)
	print("RESOURCE: " + str(resource))
	print("====================================")
	
	balloon.start(resource, title)

