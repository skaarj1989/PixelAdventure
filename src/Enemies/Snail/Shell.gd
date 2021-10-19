extends KinematicBody2D

enum Facing {LEFT = -1, RIGHT = 1}
enum {IDLE, RUN, HIT}
const ROTATE_SPEED := 160.0 # Degrees/second (on death)

var _facing = Facing.LEFT
var _speed := 6.0 # Tiles/sec

var _state := IDLE
var _velocity := Vector2.ZERO
var _last_velocity := _velocity # Before collision


func _ready() -> void:
	$AnimatedSprite.flip_h = _facing == Facing.RIGHT


func _process(_delta: float) -> void:
	if _state == HIT:
		rotation_degrees += -_facing * ROTATE_SPEED * _delta
		if GameState.is_outside(position):
			queue_free()


func _physics_process(delta: float) -> void:
	_velocity.y += GameState.GRAVITY * delta
	_last_velocity = _velocity
	_velocity = move_and_slide(_velocity, Vector2.UP)
	if _state != HIT:
		_check_collisions()


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	if _state == IDLE:
		_change_state(RUN)
	else:
		_velocity = Vector2(
			-_facing,
			-5.0
		) * GameState.TILE_SIZE
		_change_state(HIT)
		GameState.camera.add_trauma(0.5)
	
	return true


func _check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var collider = collision.collider
		if collider.is_in_group("player"):
			collider.take_damage(_last_velocity)
			_velocity = _last_velocity # Don't stop moving on collision
		elif collision.normal.x != 0:
			_turn_around()
			$AnimatedSprite.play("wall_hit")
			$Particles2D.process_material.direction.x = collision.normal.x
			$Particles2D.emitting = true
			GameState.camera.add_trauma(0.3)


func _turn_around() -> void:
	_facing = -_facing
	$AnimatedSprite.flip_h = _facing == Facing.RIGHT
	_velocity.x = _facing * _speed * GameState.TILE_SIZE


func _change_state(new_state) -> void:
	if _state == new_state:
		return
	
	match new_state:
		IDLE:
			assert(false)
		RUN:
			$AnimatedSprite.play("idle")
			$AnimatedSprite.flip_h = _facing == Facing.RIGHT
			_velocity.x = _facing * _speed * GameState.TILE_SIZE
		HIT:
			$AnimatedSprite.play("top_hit")
			$CollisionShape2D.disabled = true
		
	_state = new_state


func _on_AnimatedSprite_animation_finished() -> void:
	if $AnimatedSprite.animation == "top_hit":
		$AnimatedSprite.play("idle")
