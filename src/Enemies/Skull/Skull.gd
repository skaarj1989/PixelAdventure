extends KinematicBody2D

enum {ARMED, DISARMED, HIT}
const ROTATE_SPEED = 160 # Degrees/second

export(float) var _speed = 1.5 # Tiles/sec

var _state := DISARMED
var _velocity := Vector2.ZERO
var _last_velocity := _velocity


onready var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_velocity = Vector2(
		_rng.randf_range(-1, 1),
		_rng.randf_range(-1, 1)
	).normalized() * _speed * GameState.TILE_SIZE


func _process(_delta: float) -> void:
	if _state == HIT:
		rotation_degrees += ROTATE_SPEED * _delta
		if GameState.is_outside(position):
			queue_free()


func _physics_process(_delta: float) -> void:
	if _state == HIT:
		_velocity.y += GameState.GRAVITY * _delta
	
	_last_velocity = _velocity
	var collision = move_and_collide(_velocity * _delta)
	if _state != HIT and collision:
		var collider = collision.collider
		if collider.is_in_group("player") and collider.is_vulnerable_to(self):
			collider.take_damage(_last_velocity)
			_velocity = _last_velocity
		else:
			_velocity = _velocity.bounce(collision.normal)
			_change_state(ARMED if _state == DISARMED else DISARMED)
			GameState.camera.add_trauma(0.25)


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	if _state == DISARMED:
		_velocity = Vector2(
			-sign(_velocity.x),
			-5.0
		) * GameState.TILE_SIZE
		_change_state(HIT)
		GameState.camera.add_trauma(0.5)
		return true
	return false


func _change_state(new_state) -> void:
	if _state == new_state:
		return
	
	match new_state:
		ARMED:
			$AnimatedSprite.play("hit_wall1")
		DISARMED:
			$AnimatedSprite.play("hit_wall2")
			$DeathField/CollisionShape2D.disabled = true
		HIT:
			$AnimatedSprite.play("hit")
			$CollisionShape2D.disabled = true
		
	_state = new_state


func _on_AnimatedSprite_animation_finished() -> void:
	match $AnimatedSprite.animation:
		"hit_wall1": # Turn on death field ...
			$AnimatedSprite.play("idle1")
			$Particles2D.emitting = true
			$DeathField/CollisionShape2D.disabled = false
		"hit_wall2": # ... and off
			$AnimatedSprite.play("idle2")
			$Particles2D.emitting = false


func _on_DeathField_body_entered(body) -> void:
	if body.is_in_group("player"):
		body.take_damage(_last_velocity)
