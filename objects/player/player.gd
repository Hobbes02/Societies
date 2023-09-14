extends CharacterBody2D

signal get_tile_data

enum TileTypes{
	EMPTY,
	GRAVEL,
	BLUE_STONE,
	CONCRETE,
	DAMAGED_CONCRETE,
	GRASS,
	DIRT
}
const JUMP_VELOCITY: float = -225.0

@export var speed: float = 90.0

var sprint_speed: float = 140.0
var crouch_speed: float = 50.0
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var walk_emit: int = 10
var walk_emit_gravity: Vector2 = Vector2(0,400)
var sprint_emit: int = 14
var sprint_emit_gravity: Vector2 = Vector2(0,800)
var particle_color: Array = [
	Color(0,0,0,0),
	Color("727784"),
	Color("838997"),
	Color("929292"),
	Color("8b8b8b"),
	Color("458149"),
	Color("8d6b52")
]

var tile_pos: Vector2

var bodies_in_headspace: int = 0

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var jump_particles: CPUParticles2D = $JumpParticles
@onready var headspace_detector: Area2D = $HeadspaceDetector
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	anim_player.play("RESET")


func _physics_process(delta: float) -> void:
#	Gets tile data from the tile at 'tile_pos'
	tile_pos = Vector2(position.x, position.y + 12)
#	Falling
	if not is_on_floor():
		velocity.y += gravity * delta

#	Jumping and Jump particle emission
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump_particles.emitting = true
		jump_particles.emitting = false
		jump_particles.restart()
		velocity.y = JUMP_VELOCITY

#	Crouching
	if Input.is_action_just_pressed("crouch"):
		anim_player.play("crouch")
		headspace_detector.monitoring = true
	elif Input.is_action_just_released("crouch"):
#		Headspace Clearance
		if bodies_in_headspace > 0:
			anim_player.play("crouch")
		else:
			anim_player.play("idle")
			headspace_detector.monitoring = false

#	Walking and Walk animations
	var direction: int = Input.get_axis("walk_l", "walk_r")
	if direction:
		if Input.is_action_pressed("sprint"):
			velocity.x = direction * sprint_speed
			anim_player.play("sprint")
		elif Input.is_action_pressed("crouch"):
			velocity.x = direction * crouch_speed
			anim_player.play("crouch walk")
		else:
			velocity.x = direction * speed
			anim_player.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		if Input.is_action_pressed("crouch"):
			anim_player.play("crouch")
		else:
			anim_player.play("idle")
	move_and_slide()
	
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true


# Headspace Clearance Detection
func _on_headspace_detector_body_entered(body: Node2D) -> void:
	bodies_in_headspace += 1


func _on_headspace_detector_body_exited(body: Node2D) -> void:
	bodies_in_headspace -= 1
