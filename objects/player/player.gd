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
@export var speed: float = 95.0
@export var at_feet_tile: int
var sprint_speed: float = 140.0
var crouch_speed: float = 50.0

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

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	$AnimationPlayer.play("RESET")

func _physics_process(delta):
	tile_pos = Vector2(position.x, position.y + 12)
	emit_signal("get_tile_data")
	print(at_feet_tile)
	$WalkParticles.color = particle_color[at_feet_tile]
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		$JumpParticles.emitting = true
		$JumpParticles.emitting = false
		$JumpParticles.restart()
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("crouch"):
		$AnimationPlayer.play("crouch")
		$HeadspaceDetector.monitoring = true
	else:
		if bodies_in_headspace > 0:
			$AnimationPlayer.play("crouch")
		else:
			$AnimationPlayer.play_backwards("crouch")
			$HeadspaceDetector.monitoring = false

	if (Input.is_action_pressed("walk_l") or Input.is_action_pressed("walk_r")) and is_on_floor():
		$WalkParticles.restart()
		$WalkParticles.emitting = true
		if Input.is_action_pressed("sprint"):
			$WalkParticles.amount = sprint_emit
			$WalkParticles.gravity = sprint_emit_gravity
		elif Input.is_action_pressed("crouch"):
			$WalkParticles.emitting = false
		else:
			$WalkParticles.amount = walk_emit
			$WalkParticles.gravity = walk_emit_gravity
	elif Input.is_action_just_released("walk_l") or Input.is_action_just_released("walk_r") or not is_on_floor():
		$WalkParticles.emitting = false
	var direction = Input.get_axis("walk_l", "walk_r")
	if direction:
		if Input.is_action_pressed("sprint"):
			velocity.x = direction * sprint_speed
		elif Input.is_action_pressed("crouch"):
			velocity.x = direction * crouch_speed
		else:
			velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func _on_headspace_detector_body_entered(body: Node2D) -> void:
	bodies_in_headspace += 1

func _on_headspace_detector_body_exited(body: Node2D) -> void:
	bodies_in_headspace -= 1
