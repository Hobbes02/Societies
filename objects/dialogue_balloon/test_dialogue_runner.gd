extends BaseDialogueTestScene

const Balloon = preload("res://objects/dialogue_balloon/balloon.tscn")

func _ready() -> void:
	var balloon: Node = Balloon.instantiate()
	add_child(balloon)
	
	print("====================================")
	print("RUNNING DIALOGUE TEST")
	print("TITLE: " + title)
	print("RESOURCE: " + str(resource))
	print("====================================")
	
	balloon.start(resource, title)

