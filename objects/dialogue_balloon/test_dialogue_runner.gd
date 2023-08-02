extends BaseDialogueTestScene

const Balloon = preload("res://objects/dialogue_balloon/balloon.tscn")

func _ready() -> void:
	var balloon: Node = Balloon.instantiate()
	add_child(balloon)
	balloon.start(resource, title)

