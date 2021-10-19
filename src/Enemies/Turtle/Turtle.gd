extends KinematicBody2D

enum Facing {LEFT = -1, RIGHT = 1}
enum {ARMED, DISARMED, HIT}
const ROTATE_SPEED = 160 # Degrees/sec

export(Facing) var _facing = Facing.LEFT

var _state
var _velocity := Vector2.ZERO


onready var _rng = RandomNumberGenerator.new()

func _ready() -> void:
	$Sprite.flip_h = _facing == Facing.RIGHT
	_change_state(ARMED)
	_start_thinking()


func _process(_delta: float) -> void:
	if _state == HIT:
		rotation_degrees += -_facing * ROTATE_SPEED * _delta
		if GameState.is_outside(position):
			queue_free()


func _physics_process(_delta: float) -> void:
	_velocity.y += GameState.GRAVITY * _delta
	_velocity = move_and_slide(_velocity, Vector2.UP)
	if _state != HIT:
		_check_collisions()


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	if _state == DISARMED:
		_velocity = Vector2(
			-_facing,
			-5.0
		) * GameState.TILE_SIZE
		_change_state(HIT)
		GameState.camera.add_trauma(0.5)
		return true
	return false


func _check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var collider = collision.collider
		if collider.is_in_group("player"):
			collider.take_damage()


func _change_state(new_state) -> void:
	if _state == new_state:
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

	_state = new_state


func _start_thinking() -> void:
	_rng.randomize()
	$Timer.start(_rng.randf_range(2, 3))


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		"spikes_in":
			$AnimationPlayer.play("idle_1")
		"spikes_out":
			$AnimationPlayer.play("idle_2")


func _on_Timer_timeout() -> void:
	_change_state(ARMED if _state == DISARMED else DISARMED)
	_start_thinking()
