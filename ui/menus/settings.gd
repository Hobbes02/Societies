extends Control

@onready var tabs: TabContainer = $TabContainer


func _ready() -> void:
	tabs.current_tab = Settings.tab
