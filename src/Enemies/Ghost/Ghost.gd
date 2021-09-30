extends KinematicBody2D

enum {VISIBLE, INVISIBLE, HIT}
const PLAYER_LAYER := 1
const ENEMY_LAYER := 2
const ROTATE_SPEED := 160.0 # Degrees/second (on death)

export(GameState.FACING) var facing := GameState.FACING.RIGHT
export(float) var speed := 1.0 # Tiles/sec
# (optional) Line2D that holds exactly 2 points
export(NodePath) var patrol_path

var state
var velocity := Vector2.ZERO
var last_velocity := velocity # Before collision
var patrol_points = [] # [0] = left, [1] = right


onready var rng := RandomNumberGenerator.new()

func _ready() -> void:
	if patrol_path:
		setup_patrol_points()
	change_state(VISIBLE)


func _process(_delta: float) -> void:
	$AnimatedSprite.flip_h = facing == GameState.FACING.RIGHT
	
	if state != HIT:
		velocity.x = facing * speed * GameState.TILE_SIZE
		if patrol_path and is_patrol_point_reached():
			facing = -facing
	else:
		rotation_degrees += -facing * ROTATE_SPEED * _delta
		if GameState.is_outside(position):
			queue_free()


func _physics_process(delta: float) -> void:
	velocity.y += GameState.GRAVITY * delta
	last_velocity = velocity
	velocity = move_and_slide(velocity, Vector2.UP)
	if state != HIT:
		check_collisions()


func setup_patrol_points() -> void:
	patrol_points = Array(get_node(patrol_path).get_points())
	assert(patrol_points.size() == 2)
	patrol_points.sort() # Left to right


func check_collisions() -> void:
	for idx in range(get_slide_count()):
		var collision = get_slide_collision(idx)
		var collider = collision.collider
		if collider.is_in_group("player"):
			collider.take_damage(last_velocity)
			velocity = last_velocity # Don't stop movement on collision
			return
		elif collision.normal.x != 0:
			facing = -facing


func change_state(new_state) -> void:
	if state == new_state:
		return

	match new_state:
		VISIBLE:
			$AnimatedSprite.visible = true
			$AnimatedSprite.play("appear")
		INVISIBLE:
			$AnimatedSprite.play("disappear")
			set_collision_layer_bit(ENEMY_LAYER, false)
			set_collision_mask_bit(PLAYER_LAYER, false)
		HIT:
			$AnimatedSprite.play("hit")
			$CollisionShape2D.disabled = true
			$Timer.stop()
		
	state = new_state


func is_patrol_point_reached() -> bool:
	# Remaps facing to: [0, 1] = [left, right]
	var target = patrol_points[float(facing) * 0.5 + 0.5]
	var distance = (target - position).x
	return distance < 0 if facing == GameState.FACING.RIGHT else distance > 0 


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	velocity = Vector2(
		-facing,
		-5.0
	) * GameState.TILE_SIZE
	change_state(HIT)
	GameState.camera.add_trauma(0.5)
	return true


func _on_Timer_timeout() -> void:
	change_state(VISIBLE if state == INVISIBLE else INVISIBLE)
	rng.randomize()
	$Timer.start(rng.randf_range(2, 3))


func _on_AnimatedSprite_animation_finished() -> void:
	match $AnimatedSprite.animation:
		"appear":
			$AnimatedSprite.play("idle")
			set_collision_layer_bit(ENEMY_LAYER, true)
			set_collision_mask_bit(PLAYER_LAYER, true)
		"disappear":
			$AnimatedSprite.visible = false
