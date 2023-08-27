extends CharacterBody2D

const JUMP_VELOCITY: float = -250.0
@export var speed: float = 150.0
var bodies_in_headspace: int = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var sprint_speed: float = 175.0

func _ready() -> void:
	$AnimationPlayer.play("RESET")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
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

	var direction = Input.get_axis("walk_l", "walk_r")
	if direction:
		if Input.is_action_pressed("sprint"):
			velocity.x = direction * sprint_speed
		else:
			velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


func _on_headspace_detector_body_entered(body: Node2D) -> void:
	bodies_in_headspace += 1

func _on_headspace_detector_body_exited(body: Node2D) -> void:
	bodies_in_headspace -= 1
