extends Camera2D

# https://kidscancode.org/godot_recipes/2d/screen_shake/

export(float) var decay := 0.8  # How quickly the shaking stops [0, 1].
export(Vector2) var max_offset := Vector2(16, 16)  # Maximum hor/ver shake in pixels.
export(float) var max_roll := 0.1  # Maximum rotation in radians (use sparingly).

var trauma = 0.0  # Current shake strength.
var trauma_power := 2  # Trauma exponent. Use [2, 3].
var noise_y := 0


onready var noise := OpenSimplexNoise.new()

func _ready() -> void:
	GameState.camera = self
	
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2


func _process(delta: float) -> void:
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()


func shake() -> void:
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed * 3, noise_y)


func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)
