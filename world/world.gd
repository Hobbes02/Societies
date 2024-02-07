extends Node2D

var day_night_cycle = {
	"day": [{
		"background": Color8(230, 230, 230), 
		"sun": Color8(255, 208, 141), 
		"duration": 12 * 60,  # duration in seconds (minutes * 60)
		"chance": 1,  # 0 - 1, describes likelihood of that variant getting chosen
		"next": "dusk"
	}], 
	"dusk": [{
		"background": Color8(140, 140, 140), 
		"sun": Color8(255, 146, 87), 
		"duration": 2 * 60, 
		"chance": 0.4, 
		"next": "night"
	}, 
	{
		"background": Color8(140, 140, 140), 
		"sun": Color8(255, 208, 141), 
		"duration": 2 * 60, 
		"chance": 0.6, 
		"next": "night"
	}], 
	"night": [{
		"background": Color8(108, 108, 108), 
		"sun": Color8(0, 0, 0), 
		"duration": 5 * 60, 
		"chance": 1, 
		"next": "day"
	}]
}

var next_time: String = "day"


var focus_after_unpause: Node2D

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera
@onready var camera_following_node: Variant = player
@onready var chunks: Node2D = $Chunks
@onready var sun: PointLight2D = $Sun
@onready var night_cycle_timer: Timer = $NightCycleTimer


func _ready() -> void:
	var player_position: Vector2 = SaveManager.save_data.get("player_data", {}).get("world_position", Vector2(0, 0))
	
	if player_position != Vector2(0, 0):
		player.global_position = player_position
	
	next_time = SaveManager.save_data.get("scene_data", {}).get("time_of_day", "day")
	advance_night_cycle(true)
	
	camera.position_smoothing_enabled = false
	camera.enabled = false
	camera.global_position = camera_following_node.global_position
	camera.enabled = true
	camera.position_smoothing_enabled = true
	
	for node in get_tree().get_nodes_in_group("can_focus_camera"):
		if node.has_signal("focus_camera"):
			node.focus_camera.connect(_on_focus_camera)
		if node.has_signal("unfocus_camera"):
			node.unfocus_camera.connect(_on_unfocus_camera)
	
	SceneManager.unpaused.connect(_on_unpaused)
	
	chunks.config()
	SceneManager.pause("player", false)
	SceneManager.pause("game", false)


func _on_unpaused(layer: String) -> void:
	if layer == "game" and focus_after_unpause != null:
		_on_focus_camera(focus_after_unpause)


func _on_focus_camera(node: Node2D) -> void:
	if SceneManager.is_paused("game"):
		focus_after_unpause = node
		return
	
	camera_following_node = node


func _on_unfocus_camera() -> void:
	if SceneManager.is_paused("game"):
		focus_after_unpause = player
		return
	
	camera_following_node = player


func _process(delta: float) -> void:
	chunks.compute_parallax(camera.get_screen_center_position())
	sun.global_position = camera.get_screen_center_position() + Vector2(0, -540)
	if camera_following_node != null:
		camera.global_position = camera_following_node.global_position


func advance_night_cycle(instant: bool = false) -> void:
	var current_time_choices: Array = day_night_cycle[next_time]
	var current_time: Dictionary = {}
	
	if len(current_time_choices) == 1:
		current_time = current_time_choices[0]
	elif len(current_time_choices) > 1:
		randomize()
		var rand = float(randi_range(0, 100)) / 100
		
		current_time = current_time_choices[0]
		for choice in current_time_choices:
			if rand >= choice.chance:
				current_time = choice
				break
	else:
		return
	
	Globals.time_of_day = next_time
	
	next_time = current_time.next
	if instant:
		$CanvasModulate.color = current_time.background
		sun.color = current_time.sun
	else:
		var tween = get_tree().create_tween()
		tween.set_parallel(true)
		
		tween.tween_property($CanvasModulate, "color", current_time.background, 60)
		tween.tween_property(sun, "color", current_time.sun, 60)
		tween.set_parallel(false)
		await tween.finished
	
	night_cycle_timer.wait_time = current_time.duration
	night_cycle_timer.start()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		pass


func _on_night_cycle_timer_timeout() -> void:
	advance_night_cycle()


func _on_chunks_teleport_player(new_position: Vector2) -> void:
	camera.position_smoothing_enabled = false
	camera.enabled = false
	camera_following_node = null
	camera.global_position = (camera.get_screen_center_position() - player.global_position) + new_position + Vector2(0, 3.3)
	player.global_position = new_position
	camera.enabled = true
	camera.position_smoothing_enabled = true
	camera_following_node = player
