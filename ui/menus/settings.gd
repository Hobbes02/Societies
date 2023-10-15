extends Control

@onready var tabs: TabContainer = $TabContainer
@onready var keybind_popup: Window = $TabContainer/Keybinds/ChangeKeybind


func _ready() -> void:
	tabs.current_tab = Settings.tab


func _process(delta: float) -> void:
	pass
