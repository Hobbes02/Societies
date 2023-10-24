extends Control

@onready var tabs: TabContainer = $TabContainer


func _ready() -> void:
	tabs.current_tab = Settings.tab


func _process(delta: float) -> void:
	if tabs.current_tab == 3:
		get_tree().change_scene_to_file("res://ui/menus/main_menu.tscn")
