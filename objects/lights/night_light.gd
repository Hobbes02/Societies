class_name NightLight
extends PointLight2D

## Array of times of day when the light should be active
@export var active_during: Array[String] = ["night"]

## Time (in seconds) between the light being activated and it reaching its full brightness
@export var warm_up_time: float = 30.0

## Should the light simulate flicker?
@export var flicker: bool = false

var tween

var flicker_value: float = 0.0
var max_flicker_noise_value: int = 1000000

@onready var light_active_energy: float = energy
@onready var flicker_noise = FastNoiseLite.new()


func _ready() -> void:
	Globals.time_of_day_changed.connect(_on_time_of_day_changed)
	energy = light_active_energy if Globals.time_of_day in active_during else 0
	if flicker:
		flicker_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
		randomize()
		flicker_value = randi() % max_flicker_noise_value
		set_process(true)
	else:
		set_process(false)


func _process(delta: float) -> void:
	flicker_value += 0.5
	
	if flicker_value > max_flicker_noise_value:
		flicker_value = 0
	
	energy = flicker_noise.get_noise_1d(flicker_value) / 2 + 1


func _on_time_of_day_changed(to: String) -> void:
	if tween:
		tween.kill()
	
	tween = get_tree().create_tween()
		
	if to in active_during:
		tween.tween_property(self, "energy", light_active_energy, warm_up_time)
	else:
		tween.tween_property(self, "energy", 0, warm_up_time)
