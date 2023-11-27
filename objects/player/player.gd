class_name Player
extends CharacterBody2D

enum MoveStates {
	Walk, 
	Crawl, 
	Sprint, 
}

const JUMP_VELOCITY: float = -225.0

var speed: float = 90.0
var sprint_speed: float = 140.0
var crouch_speed: float = 40.0

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_move_state: MoveStates = MoveStates.Walk

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var jump_buffer: Timer = $JumpBuffer
@onready var coyote_timer: Timer = $CoyoteTime
@onready var headspace_detector: RayCast2D = $HeadSpaceDetector
@onready var jump_detector: RayCast2D = $JumpDetector


func _ready() -> void:
	anim_player.play("RESET")
	SceneManager.paused.connect(_on_pause)
	
	SaveManager.about_to_save.connect(_about_to_save)
	SaveManager.just_loaded.connect(_just_loaded)


func _about_to_save() -> void:
	SaveManager.save_data.player_data = SaveManager.save_data.get("player_data", SaveManager.DEFAULT_SAVE_DATA.player_data)
	SaveManager.save_data.player_data.position = global_position


func _just_loaded() -> void:
	global_position = SaveManager.get_value("player_data/position", global_position)
	await get_tree().create_timer(0.2).timeout
	if headspace_detector.is_colliding():
		current_move_state = MoveStates.Crawl
		anim_player.play("crawl idle")


func _on_pause(layer: String) -> void:
	if layer in ["player", "game", "all"]:
		anim_player.play("crawl idle" if headspace_detector.is_colliding() else "idle")
		velocity.x = 0


func _physics_process(delta: float) -> void:
#	Falling
	if not is_on_floor():
		velocity.y += gravity * delta

	if SceneManager.is_paused("player", ["game"]):
		return

#	Jumping
	if Input.is_action_just_pressed("jump") and not headspace_detector.is_colliding() and not jump_detector.is_colliding():
		if is_on_floor() or not coyote_timer.is_stopped():
			velocity.y = JUMP_VELOCITY
			coyote_timer.stop()
		else:
			jump_buffer.start()

#	Walking
	handle_movement(delta)
	
	handle_animations()


func handle_movement(delta: float) -> void:
	if Input.is_action_pressed("crawl"):
		current_move_state = MoveStates.Crawl
	elif Input.is_action_pressed("sprint"):
		current_move_state = MoveStates.Sprint
	else:
		if headspace_detector.is_colliding() and current_move_state == MoveStates.Crawl:
			current_move_state = MoveStates.Crawl
		else:
			current_move_state = MoveStates.Walk
	
	var direction: int = Input.get_axis("walk_left", "walk_right")
	if direction:
		if current_move_state == MoveStates.Sprint:
			velocity.x = direction * sprint_speed
		elif current_move_state == MoveStates.Crawl:
			velocity.x = direction * crouch_speed
		else:
			velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()


func handle_animations() -> void:
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true
	if velocity.y == 0:
		match current_move_state:
			MoveStates.Walk:
				if velocity.x != 0:
					anim_player.play("walk")
				else:
					anim_player.play("idle")
			MoveStates.Sprint:
				if velocity.x != 0:
					anim_player.play("sprint")
				else:
					anim_player.play("idle")
			MoveStates.Crawl:
				if velocity.x != 0:
					anim_player.play("crawl")
				else:
					anim_player.play("crawl idle")
	else:
		anim_player.play("jump")


func _on_land_detector_body_entered(body: Node2D) -> void:
	if not jump_buffer.is_stopped():
		if not jump_detector.is_colliding():
			velocity.y = JUMP_VELOCITY
		jump_buffer.stop()


func _on_land_detector_body_exited(body: Node2D) -> void:
	if velocity.y < 0:
		return
	if coyote_timer and coyote_timer.is_inside_tree():
		coyote_timer.start()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PAUSED:
			if headspace_detector.is_colliding():
				anim_player.play("crawl idle")
			else:
				anim_player.play("idle")
