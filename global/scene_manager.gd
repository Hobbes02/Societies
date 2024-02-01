extends Node

signal _background_load_finished()

signal scenes_ready()
signal paused(layer: String)
signal unpaused(layer: String)

@export_file("*.tscn") var start_scene: String = ""
@export var pause_layers: Dictionary = {
	"entities": false, 
	"interaction": false, 
	"all": false
} :
	set(new_value):
		for key in pause_layers.keys():
			if pause_layers[key] != new_value[key]:
				if new_value[key]:
					paused.emit(key)
				else:
					unpaused.emit(key)
				break
		
		pause_layers = new_value

## Defines what scenes can be saved as the current scene in the savegame (scenes that are part of the game)
@export var play_scenes: Array[String] = []

var progress: Array = []
var scene_load_status: ResourceLoader.ThreadLoadStatus = 0

var previous_frame_progress: int = -1

var currently_loading_scene: String = ""
var loaded_scene

var active_scene: String = ""
var active_scene_node: Node

var are_scenes_ready: bool = false

var scene_history: Array = []
var level_history: Array = [] : # array of the past 8 levels the player's been to
	set(new_value):
		level_history = new_value
		if len(level_history) > 8:
			level_history.pop_back()

var persistent_information: Dictionary = {}

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar: ProgressBar = $Visuals/ColorRect/CenterContainer/ProgressBar
@onready var visuals: CanvasLayer = $Visuals
@onready var scenes: Node = $Scenes


func _ready() -> void:
	if str(get_tree().current_scene.get_path()) != "/root/blank":
		$Visuals/ColorRect.hide()
		$Visuals/ColorRect.mouse_filter = $Visuals/ColorRect.MOUSE_FILTER_IGNORE
		return
	
	scenes_ready.connect(
		func():
			are_scenes_ready = true
	)
	$Visuals/ColorRect.global_position = Vector2(
		0, 
		0
	)
	await change_scene(start_scene, false, true, scenes_ready)
	
	SaveManager.about_to_save.connect(_save)


func _save(reason: SaveManager.SaveReason) -> void:
	SaveManager.save_data.scene_data = SaveManager.save_data.get("scene_data", SaveManager.DEFAULT_SAVE_DATA.scene_data)
	SaveManager.save_data.scene_data.level_history = level_history


func change_scene(filename: String, slide_in: bool = true, slide_out: bool = true, emit_after_loading: Variant = null, data_to_pass: Variant = null, pass_before_instantiate: bool = false) -> void:
	visuals.show()
	if slide_in:
		animation_player.play("fade")
		await animation_player.animation_finished
		await get_tree().create_timer(0.2).timeout
	else:
		await get_tree().create_timer(0.2).timeout
	
	active_scene = filename
	if active_scene_node:
		active_scene_node.queue_free()
		active_scene_node = null
	pause_layers[filename] = false
	await _load_scene(filename, data_to_pass if pass_before_instantiate else null)
	
	if typeof(emit_after_loading) == TYPE_SIGNAL:
		emit_after_loading.emit()
	if typeof(data_to_pass) == TYPE_DICTIONARY and not pass_before_instantiate:
		for key in data_to_pass.keys():
			if typeof(active_scene_node.get(key)) == typeof(data_to_pass[key]):
				active_scene_node.set(key, data_to_pass[key])
	
	SaveManager.save_data.scene_data = SaveManager.save_data.get("scene_data", SaveManager.DEFAULT_SAVE_DATA.scene_data)
	if filename in play_scenes:
		SaveManager.save_data.scene_data.current_scene = filename.lstrip("res://").rstrip(".tscn")
	
	scene_history.append(filename)
	
	progress_bar.hide()
	if slide_out:
		animation_player.play_backwards("fade")
		await animation_player.animation_finished


func is_paused(layer: String, others: Array = []) -> bool:
	if others != []:
		for l in others:
			if pause_layers.has(l) and pause_layers[l]:
				return true
	return (pause_layers.has(layer) and pause_layers[layer]) or pause_layers["all"]


func pause(layer: String, is_paused: bool) -> void:
	if pause_layers.has(layer):
		pause_layers[layer] = is_paused


func add_pause_layer(layer_name: String, default: bool = false) -> void:
	pause_layers[layer_name] = default


func get_persistent_information(key: String) -> Variant:
	return persistent_information.get(key, null)


func set_persistent_information(key: String, value: Variant) -> void:
	persistent_information[key] = value


func _load_scene(scene_path: String, data_to_pass: Variant = null) -> void:
	if (not scene_path.begins_with("res://")) or (not scene_path.ends_with(".tscn")):
		return
	ResourceLoader.load_threaded_request(scene_path)
	currently_loading_scene = scene_path
	set_process(true)
	await self._background_load_finished
	currently_loading_scene = ""
	
	var scene = loaded_scene.instantiate()
	
	if typeof(data_to_pass) == TYPE_DICTIONARY:
		for key in data_to_pass.keys():
			if typeof(scene.get(key)) == typeof(data_to_pass[key]):
				scene.set(key, data_to_pass[key])
	
	scenes.add_child(scene)
	
	active_scene = scene_path
	active_scene_node = scene


func _process(delta: float) -> void:
	if currently_loading_scene == "":
		return
	
	scene_load_status = ResourceLoader.load_threaded_get_status(currently_loading_scene, progress)
	
	if previous_frame_progress != progress[0] * 100:
		progress_bar.value = progress[0] * 100
	previous_frame_progress = progress[0] * 100
	
	match scene_load_status:
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_scene = ResourceLoader.load_threaded_get(currently_loading_scene)
			_background_load_finished.emit()
			set_process(false)
		ResourceLoader.THREAD_LOAD_FAILED:
			progress_bar.hide()
			set_process(false)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			Engine.max_fps = 8
		NOTIFICATION_APPLICATION_FOCUS_IN:
			Engine.max_fps = 0
