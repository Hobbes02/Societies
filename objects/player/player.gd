extends CharacterBody2D

enum MoveStates {
	Walk, 
	Crouch, 
	Sprint, 
}

const JUMP_VELOCITY: float = -225.0

var speed: float = 90.0
var sprint_speed: float = 140.0
var crouch_speed: float = 40.0

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_move_state: MoveStates = MoveStates.Walk

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var jump_particles: CPUParticles2D = $JumpParticles
@onready var sprite: Sprite2D = $Sprite2D
@onready var jump_buffer: Timer = $JumpBuffer


func _ready() -> void:
	anim_player.play("RESET")


func _physics_process(delta: float) -> void:
#	Falling
	if not is_on_floor():
		velocity.y += gravity * delta

#	Jumping
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		else:
			jump_buffer.start()

#	Walking
	handle_movement(delta)
	
	handle_animations()


func handle_movement(delta: float) -> void:
	var direction: int = Input.get_axis("walk_l", "walk_r")
	if direction:
		if Input.is_action_pressed("sprint"):
			velocity.x = direction * sprint_speed
		elif Input.is_action_pressed("crouch"):
			velocity.x = direction * crouch_speed
		else:
			velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	if Input.is_action_pressed("sprint"):
		current_move_state = MoveStates.Sprint
	elif Input.is_action_pressed("crouch"):
		current_move_state = MoveStates.Crouch
	else:
		current_move_state = MoveStates.Walk
	
	move_and_slide()


func handle_animations() -> void:
	if velocity.y == 0:
		if velocity.x > 0:
			sprite.flip_h = false
		elif velocity.x < 0:
			sprite.flip_h = true
		
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
			MoveStates.Crouch:
				if velocity.x != 0:
					anim_player.play("crouch walk")
				else:
					anim_player.play("crouch")
	else:
		anim_player.play("jump")
