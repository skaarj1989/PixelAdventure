extends KinematicBody2D

enum {ON, OFF}

export(Vector2) var displacement := Vector2(0, 5) # In pixels
export(float) var speed = 0.1 # Tiles/sec

var state := ON
var velocity := Vector2.ZERO
var patrol_points = []
var patrol_index := -1


onready var rng := RandomNumberGenerator.new()

func _ready() -> void:
	start_tween()


func _process(_delta: float) -> void:
	if state == OFF and GameState.is_outside(position):
		queue_free()


func _physics_process(delta: float) -> void:
	if state == OFF:
		velocity.y += GameState.GRAVITY * delta
	
	var last_position = position
	var collision = move_and_collide(velocity * delta)
	if state == ON and collision:
		var collider = collision.collider
		if collider.is_in_group("player"):
			position = last_position
			if collision.normal == Vector2.DOWN and $Timer.is_stopped():
				$Timer.start()


func start_tween() -> void:
	var duration = displacement.length() / float(GameState.TILE_SIZE * speed)
	$Tween.interpolate_property(
			self,
			"position",
			position,
			position + displacement,
			duration,
			Tween.TRANS_SINE,
			Tween.EASE_IN_OUT,
			1.0)
	$Tween.start()


func change_state(new_state) -> void:
	if state == new_state:
		return
	
	match new_state:
		ON:
			$AnimatedSprite.play("on")
			$Particles2D.emitting = true
		OFF:
			$AnimatedSprite.play("off")
			$Particles2D.emitting = false
			$CollisionShape2D.disabled = true
			$Tween.stop_all()
	
	state = new_state


func _on_Tween_tween_completed(_object, _key) -> void:
	displacement = -displacement
	start_tween()


func _on_Timer_timeout() -> void:
	change_state(OFF)
