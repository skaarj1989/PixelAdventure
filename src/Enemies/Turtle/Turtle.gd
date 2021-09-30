extends KinematicBody2D

enum {ARMED, DISARMED, HIT}
const ROTATE_SPEED = 160 # Degrees/sec

export(GameState.FACING) var facing := GameState.FACING.RIGHT

var state
var velocity := Vector2.ZERO


onready var rng = RandomNumberGenerator.new()

func _ready() -> void:
	$Sprite.flip_h = facing == GameState.FACING.RIGHT
	change_state(ARMED)
	start_thinking()


func _process(_delta: float) -> void:
	if state == HIT:
		rotation_degrees += -facing * ROTATE_SPEED * _delta
		if GameState.is_outside(position):
			queue_free()


func _physics_process(_delta: float) -> void:
	velocity.y += GameState.GRAVITY * _delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if state != HIT:
		check_collisions()


func check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var collider = collision.collider
		if collider.is_in_group("player"):
			collider.take_damage()


func change_state(new_state) -> void:
	if state == new_state:
		return
	
	match new_state:
		ARMED:
			$AnimationPlayer.play("spikes_in")
		DISARMED:
			$AnimationPlayer.play("spikes_out")
		HIT:
			$AnimationPlayer.play("hit")
			$CollisionShape2D.disabled = true
			$Timer.stop()

	state = new_state


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	if state == DISARMED:
		velocity = Vector2(
			-facing,
			-5.0
		) * GameState.TILE_SIZE
		change_state(HIT)
		GameState.camera.add_trauma(0.5)
		return true
	return false


func start_thinking() -> void:
	rng.randomize()
	$Timer.start(rng.randf_range(2, 3))


func _on_Timer_timeout() -> void:
	change_state(ARMED if state == DISARMED else DISARMED)
	start_thinking()


func _on_AnimationPlayer_animation_finished(anim_name) -> void:
	match anim_name:
		"spikes_in":
			$AnimationPlayer.play("idle_1")
		"spikes_out":
			$AnimationPlayer.play("idle_2")
