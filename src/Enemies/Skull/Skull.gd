extends KinematicBody2D

enum {ARMED, DISARMED, HIT}
const ROTATE_SPEED = 160 # Degrees/second

export(float) var speed := 1.5 # Tiles/sec

var state := DISARMED
var velocity := Vector2.ZERO
var last_velocity := velocity


onready var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	velocity = Vector2(
		rng.randf_range(-1, 1),
		rng.randf_range(-1, 1)
	).normalized() * speed * GameState.TILE_SIZE


func _process(_delta: float) -> void:
	if state == HIT:
		rotation_degrees += ROTATE_SPEED * _delta
		if GameState.is_outside(position):
			queue_free()


func _physics_process(_delta: float) -> void:
	if state == HIT:
		velocity.y += GameState.GRAVITY * _delta
	
	last_velocity = velocity
	var collision = move_and_collide(velocity * _delta)
	if state != HIT and collision:
		var collider = collision.collider
		if collider.is_in_group("player") and collider.is_vulnerable_to(self):
			collider.take_damage(last_velocity)
			velocity = last_velocity
		else:
			velocity = velocity.bounce(collision.normal)
			change_state(ARMED if state == DISARMED else DISARMED)
			GameState.camera.add_trauma(0.25)


func change_state(new_state) -> void:
	if state == new_state:
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
		
	state = new_state


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	if state == DISARMED:
		velocity = Vector2(
			-sign(velocity.x),
			-5.0
		) * GameState.TILE_SIZE
		change_state(HIT)
		GameState.camera.add_trauma(0.5)
		return true
	return false


func _on_AnimatedSprite_animation_finished() -> void:
	match $AnimatedSprite.animation:
		"hit_wall1": # Turn on death field ...
			$AnimatedSprite.play("idle1")
			$DeathField/CollisionShape2D.disabled = false
		"hit_wall2": # ... and off
			$AnimatedSprite.play("idle2")


func _on_DeathField_body_entered(body) -> void:
	if body.is_in_group("player"):
		body.take_damage(last_velocity)
