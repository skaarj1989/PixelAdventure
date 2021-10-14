extends KinematicBody2D

enum {IDLE, RUN, HIT}
const ROTATE_SPEED := 160.0 # Degrees/second (on death)

var facing := 1
var speed := 6.0 # Tiles/sec

var state := IDLE
var velocity := Vector2.ZERO
var last_velocity := velocity # Before collision


func _ready() -> void:
	$AnimatedSprite.flip_h = facing == GameState.FACING.RIGHT


func _process(_delta: float) -> void:
	if state == HIT:
		rotation_degrees += -facing * ROTATE_SPEED * _delta
		if GameState.is_outside(position):
			queue_free()


func _physics_process(delta: float) -> void:
	velocity.y += GameState.GRAVITY * delta
	last_velocity = velocity
	velocity = move_and_slide(velocity, Vector2.UP)
	if state != HIT:
		_check_collisions()


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	if state == IDLE:
		_change_state(RUN)
	else:
		velocity = Vector2(
			-facing,
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
			collider.take_damage(last_velocity)
			velocity = last_velocity # Don't stop moving on collision
		elif collision.normal.x != 0:
			_turn_around()
			$AnimatedSprite.play("wall_hit")
			$Particles2D.process_material.direction.x = collision.normal.x
			$Particles2D.emitting = true
			GameState.camera.add_trauma(0.3)


func _turn_around() -> void:
	facing = -facing
	$AnimatedSprite.flip_h = facing == GameState.FACING.RIGHT
	velocity.x = facing * speed * GameState.TILE_SIZE


func _change_state(new_state) -> void:
	if state == new_state:
		return
	
	match new_state:
		IDLE:
			assert(false)
		RUN:
			$AnimatedSprite.play("idle")
			$AnimatedSprite.flip_h = facing == GameState.FACING.RIGHT
			velocity.x = facing * speed * GameState.TILE_SIZE
		HIT:
			$AnimatedSprite.play("top_hit")
			$CollisionShape2D.disabled = true
		
	state = new_state



func _on_AnimatedSprite_animation_finished() -> void:
	if $AnimatedSprite.animation == "top_hit":
		$AnimatedSprite.play("idle")
